@test "runs webapp" {
  status webapp | grep running
}

@test "runs znc" {
  status znc | grep running
}

@test "runs collectd" {
  status collectd | grep running
}

@test "runs postgres" {
  service postgresql-9.3 status | grep running
}

@test "valid certs for joelt.io" {
  failed=0
  echo "127.0.0.1 joelt.io" >> /etc/hosts
  curl -s https://joelt.io || failed=1
  sed -i '/joelt.io/d' /etc/hosts
  return $failed
}
