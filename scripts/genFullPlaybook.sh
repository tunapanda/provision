#!/bin/bash
cat > fullPlaybook.yml <<EOF
---
### AUTO-GENERATED ###
- hosts: all
  pre_tasks:
    - file: path='{{ provision__base_dir }}' state=directory
        owner=root group=root mode=0755
    - shell: echo "Last provisioning started at \$(date)" > {{ provision__base_dir }}/provisioning.txt
  post_tasks:
    - shell: echo "Last provisioning completed at \$(date)" >> {{ provision__base_dir }}/provisioning.txt

  roles:
EOF

for r in $(find roles/ -maxdepth 1 -mindepth 1 -type d)
  do
  f=$(basename $r);
  echo "    - role: $f" >> fullPlaybook.yml
done

echo "" >> fullPlaybook.yml
echo "  vars:" >> fullPlaybook.yml

(for r in $(ls roles/) ;
    do 
    if [ -f roles/$r/defaults/main.yml ];
        then echo "" ;
	echo "    ## $r role" ;
	cat roles/$r/defaults/main.yml | grep -v '^---' | grep -v '^[[:space:]]*$' | sed 's,^,    ,';
    fi
 done) >> fullPlaybook.yml
