file node["webapp"]["cert_path"] do
  content Chef::EncryptedDataBagItem.load("webapp", "certs")["ssl_cert"]
end

file node["webapp"]["key_path"] do
  content Chef::EncryptedDataBagItem.load("webapp", "certs")["ssl_key"]
end
