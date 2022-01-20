---
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
    - name: /opt/gitlab/bin/gitlab-backup create CRON=1
    - user: root
    - special: '@daily'
    - require:
      - pkg: cron

# HOURLY RSYNC
# Ensure the GitLab backups directory is synced with the NFS share.  This will run hourly so the NFS share will at most
# be out of sync for 1 hours.  We use the delete option so the maximum backups option in GitLab also applies here.
hourly_rsync:
  cron.present:
    - name: rsync -vu --delete /var/opt/gitlab/backups/ /mnt/ftpback-rbx2-173.ovh.net/git01
    - user: root
    - special: '@hourly'
    - require:
      - pkg: cron
