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

# INSTALL CRON
# On live environments this will almost certainly be installed but when running inside a container the cron package is
# not pre-installed, so we include this state to ensure it is always available.
cron:
  pkg.installed

# DAILY BACKUP
# Run GitLab backup daily.  This will manage old backups for us too, by default deleting backups older than 7 days.  The
# CRON option cuts down on spam by only outputting errors.  Daily backups should be sufficient for now.
daily_backup:
  cron.present:
    - name: /opt/gitlab/bin/gitlab-backup create DIRECTORY=/mnt/ftpback-rbx2-173.ovh.net/git01/ CRON=1
    - user: root
    - special: '@daily'
    - require:
      - pkg: cron
