#!/bin/bash
FAIL=0

if [ ! -f /opt/course/14/expiration ]; then
  echo "FAIL: /opt/course/14/expiration does not exist"
  FAIL=1
else
  ACTUAL_CONTENT=$(cat /opt/course/14/expiration)
  REAL_ENDDATE=$(openssl x509 -in /etc/kubernetes/pki/apiserver.crt -noout -enddate 2>/dev/null | cut -d= -f2)

  if [ -z "$REAL_ENDDATE" ]; then
    echo "WARN: could not read /etc/kubernetes/pki/apiserver.crt on this host to verify - skipping strict compare"
  else
    # Compare as dates (allow for formatting differences)
    REAL_EPOCH=$(date -d "$REAL_ENDDATE" +%s 2>/dev/null)
    ACTUAL_EPOCH=$(date -d "$ACTUAL_CONTENT" +%s 2>/dev/null)
    if [ -n "$REAL_EPOCH" ] && [ -n "$ACTUAL_EPOCH" ] && [ "$REAL_EPOCH" == "$ACTUAL_EPOCH" ]; then
      echo "PASS: expiration file matches actual apiserver.crt expiration"
    else
      echo "FAIL: expiration file content ('$ACTUAL_CONTENT') does not match actual cert expiration ('$REAL_ENDDATE')"
      FAIL=1
    fi
  fi
fi

if [ ! -f /opt/course/14/kubeadm-renew-certs.sh ]; then
  echo "FAIL: /opt/course/14/kubeadm-renew-certs.sh does not exist"
  FAIL=1
else
  CONTENT=$(cat /opt/course/14/kubeadm-renew-certs.sh)
  if echo "$CONTENT" | grep -qE "kubeadm certs renew apiserver"; then
    echo "PASS: kubeadm-renew-certs.sh contains correct renew command"
  else
    echo "FAIL: kubeadm-renew-certs.sh does not contain 'kubeadm certs renew apiserver'"
    FAIL=1
  fi
fi

if [ $FAIL -eq 0 ]; then
  echo "==== ALL CHECKS PASSED ===="
  exit 0
else
  echo "==== SOME CHECKS FAILED ===="
  exit 1
fi
