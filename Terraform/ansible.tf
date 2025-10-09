
# Generate Ansible inventory file automatically
resource "local_file" "ansible_inventory" {
  content = templatefile("${path.module}/../ansible/inventory.tpl", {
    ec2_public_ip = aws_instance.web.public_ip
    ssh_key_path  = var.key_path
  })
  filename = "${path.module}/../ansible/inventory.ini"
}

# Run Ansible on the VM itself
resource "null_resource" "ansible_provision" {
  depends_on = [aws_instance.web]

  provisioner "file" {
    source      = "${path.module}/../ansible/playbook.yml"
    destination = "/tmp/playbook.yml"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.key_path)
      host        = aws_instance.web.public_ip
    }
  }

  provisioner "file" {
    source      = "${path.module}/../ansible/requirements.yml"
    destination = "/tmp/requirements.yml"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.key_path)
      host        = aws_instance.web.public_ip
    }
  }

  provisioner "remote-exec" {
    inline = [
      "sleep 30",
      "sudo apt update -y",
      "sudo apt install -y python3-pip",
      "pip3 install ansible",
      "ansible-galaxy collection install -r /tmp/requirements.yml",
      "echo '[webserver]' > /tmp/inventory",
      "echo 'localhost ansible_connection=local' >> /tmp/inventory",
      "sudo systemctl stop nginx || true",
      "ansible-playbook -i /tmp/inventory /tmp/playbook.yml"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file(var.key_path)
      host        = aws_instance.web.public_ip
    }
  }
}