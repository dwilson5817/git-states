---
{% for mount, args in pillar.get('nfs_mounts', {}).items() %}

# MOUNT NFS FILESYSTEM(S)
# Most of the code here is exactly the same as core.nfs but GitLab requires the filesystem to be mounted as the git user
# instead of root, so we use the exact same options as core.nfs but also mount it as Git.
mount_{{ mount }}_git:
  file.directory:
    - name: /mnt/{{ mount }}
  mount.mounted:
    - name: /mnt/{{ mount }}
    - device: {{ mount }}:{{ args.remote_directory }}
    - user: git
    - mkmnt: true
    - fstype: nfs
    - require:
      - file: /mnt/{{ mount }}

{% endfor %}
