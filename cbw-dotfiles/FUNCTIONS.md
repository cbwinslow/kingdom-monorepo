# Function Reference

This document provides a comprehensive list of all 796 functions organized by category.

## Statistics

- **Total Functions**: 796
- **Total Aliases**: 195
- **Function Categories**: 11
- **Lines of Code**: ~50,000+

## Quick Reference by Category

### 01-navigation.sh (17 functions)
Directory navigation and management utilities.

| Function | Description |
|----------|-------------|
| `mkcd` | Create directory and cd into it |
| `up` | Go up N directories |
| `cdgr` | Go to root of git repository |
| `cdpr` | Go to project root |
| `backup_here` | Create backup of current directory |
| `bookmark` | Add directory bookmark |
| `goto` | Jump to bookmarked directory |
| `rmbookmark` | Remove bookmark |
| `dirs_add` | Add to directory stack |
| `dirs_back` | Pop from directory stack |
| `dirs_list` | List directory stack |
| `fcd` | Fuzzy find and cd to directory |
| `cdtmp` | Create and cd to temp directory |
| `upto` | Jump to parent directory containing file |
| `cdl` | Go to Downloads |
| `cdp` | Go to Projects |
| `cdd` | Go to Desktop |
| `cdo` | Go to Documents |

### 02-file-operations.sh (68 functions)
File management, searching, and manipulation.

**Archive Operations**: `extract`, `archive`  
**Backup**: `backup`, `backup_numbered`  
**Search**: `ff`, `fd`, `findtext`, `findreplace`, `finddupes`  
**Size**: `filesize`, `countlines`, `countfiles`, `countdirs`, `largest`  
**Recent**: `recent`  
**Comparison**: `dirdiff`, `dirsync`  
**Permissions**: `mkexec`, `octalperm`  
**Viewing**: `view`, `cpv`, `mvv`  
**Manipulation**: `noext`, `changeext`, `batch_rename`  
**Content**: `mkfile`, `appendfile`, `search`, `isearch`  
**Empty**: `listempty`, `rmempty`  
**Clipboard**: `paste_to_file`, `copy_file`

### 03-git-operations.sh (103 functions)
Comprehensive Git operations and shortcuts.

**Basic Operations**: `gs`, `gaa`, `gc`, `gac`, `gacp`, `gp`, `gpl`, `gpr`  
**Branches**: `gco`, `gcb`, `gb`, `gbd`, `gbD`, `gba`, `gcurrent`, `gcleanup`  
**Commits**: `gundo`, `gamend`, `gamendm`, `glast`, `qcommit`  
**Diff**: `gd`, `gdc`, `gcompare`  
**Log**: `gl`, `gls`, `glsearch`, `gfind`, `ghistory`, `ggraph`  
**Stash**: `gst`, `gstp`, `gstl`  
**Remote**: `gr`, `gf`, `gremotes`, `gaddremote`, `grmremote`  
**Merge/Rebase**: `gm`, `grb`, `grbi`, `gabort`, `gcontinue`, `gskip`  
**Reset**: `grs`, `grsh`, `gclean`  
**Tags**: `gtags`, `gtag`, `gpush_tags`  
**Worktree**: `gwt_add`, `gwt_list`, `gwt_rm`  
**Authors**: `gauthors`, `gstats`  
**Conflicts**: `gconflicts`  
**Archive**: `garchive`, `garchived`  
**Patch**: `gpatch`, `gapply`  
**Submodules**: `gclsub`, `gsubupdate`  
**Advanced**: `gbisect_*`, `gsize`, `gblame`, `gshow`, `gcp`

### 04-docker-operations.sh (94 functions)
Docker and Docker Compose management.

**Container Operations**: `dps`, `dpsa`, `dr`, `dri`, `dex`, `dexr`, `dshell`  
**Logs**: `dl`, `dlf`  
**Lifecycle**: `dst`, `dstop_all`, `dstart`, `drestart`, `dkill_all`  
**Removal**: `drm`, `drmf`, `drm_stopped`, `dclean`  
**Images**: `di`, `db`, `dbuild_nc`, `drmi`, `drmi_all`, `drmi_dangling`  
**Inspection**: `dins`, `dstats`, `dstat`, `denv`, `dports`, `dip`, `dname`  
**Files**: `dcp_from`, `dcp_to`  
**Utilities**: `drun_here`, `ddisk`, `dfile`  
**Compose**: `dcup`, `dcupd`, `dcdown`, `dcrestart`, `dclogs`, `dclogsf`, `dcbuild`, `dcps`, `dcex`  
**Volumes**: `dvls`, `dvrm`, `dvprune`, `dvol_create`, `dvol_inspect`  
**Networks**: `dnls`, `dnrm`, `dnprune`, `dnet_*`  
**Registry**: `dtag`, `dpush`, `dpull`, `dsearch`, `dlogin`, `dlogout`  
**Advanced**: `dcommit`, `dexport`, `dimport`, `dsave`, `dload`, `dtop`, `dpause`, `dunpause`

### 05-kubernetes.sh (103 functions)
Kubernetes resource management and operations.

**Pods**: `kgp`, `kgpa`, `kdp`, `kdelp`, `kgpn`, `kgpage`  
**Services**: `kgs`, `kds`, `kdels`, `ksvcip`  
**Deployments**: `kgd`, `kdd`, `kdeld`, `kscale`, `krestart`  
**Nodes**: `kgn`, `kdnode`, `knodeips`, `kdrain`, `kcordon`, `kuncordon`, `ktaint`  
**Namespaces**: `kgns`, `kcns`, `kns`  
**Logs**: `kl`, `klf`, `klp`, `kld`, `klogs_all`  
**Exec**: `kex`, `kexsh`, `kshell`  
**Apply/Delete**: `ka`, `kdel`  
**Events**: `kge`  
**All Resources**: `kga`, `kgan`  
**Rollout**: `krs`, `krh`, `kru`  
**Port Forward**: `kpf`  
**Top**: `ktop`, `ktopn`, `kres`  
**Context**: `kctx`, `kusectx`, `kcurrent`  
**Labels**: `klabel`, `kgpl`, `kgpbl`  
**ConfigMaps**: `kgcm`  
**Secrets**: `kgsec`  
**Ingress**: `kgi`  
**Volumes**: `kgpv`, `kgpvc`  
**Workloads**: `kgrs`, `kgss`, `kgds`, `kgj`, `kgcj`  
**Edit**: `ked`, `kpatch`  
**Output**: `kgy`, `kgj`  
**Utilities**: `kwait`, `kdebug`, `kdiff`, `kexplain`, `kapi`, `kinfo`, `kversion`  
**Status**: `kfailing`, `kpending`, `kquota`, `klimit`  
**Watch**: `kwp`, `kwa`  
**Auth**: `kauth`, `kgsa`, `kgrole`, `kgcrole`, `kgrb`, `kgcrb`

### 06-system-utilities.sh (130 functions)
System management and monitoring.

**System Info**: `diskusage`, `meminfo`, `cpuinfo`, `uptime_info`, `sysinfo`, `hardware`  
**Processes**: `procs`, `killproc`, `killport`, `topcpu`, `topmem`, `zombies`  
**Network**: `ports`, `check_port`, `listening`, `netconns`, `myip`, `localip`, `allips`  
**DNS**: `lookup`, `diginfo`, `flush_dns`  
**Monitoring**: `load`, `monitor`, `battery`, `temp`, `diskio`, `bandwidth`  
**Services**: `services`, `startservice`, `stopservice`, `restartservice`, `statusservice`, `enableservice`, `disableservice`  
**Logs**: `logs`, `bootlogs`  
**Users**: `whoson`, `lastlogin`, `userinfo`, `listusers`, `listgroups`, `addusergroup`  
**Environment**: `showenv`, `setenv_perm`, `showpath`, `addpath`, `reload`  
**Aliases**: `mkalias`, `lsalias`, `rmalias`  
**Cron**: `crons`, `editcron`, `backupcron`, `scheduled`  
**System Control**: `reboot_system`, `shutdown_system`  
**Commands**: `command_exists`, `whichcmd`, `whereis_cmd`  
**Files**: `filetype`, `md5`, `sha256`, `checksum_verify`  
**Time**: `datetime`, `ts2date`, `timestamp`, `stopwatch`, `timer`  
**Utilities**: `serve_http`, `genpass`, `genuuid`, `mimetype`, `usb`, `pci`, `modules`  
**Cache**: `clearcache`  
**Utilities**: `bell`, `repeat`, `until_success`, `until_fail`

### 07-development.sh (150 functions)
Development tools and helpers for multiple languages.

**Node.js**: `node_version`, `npm_global`, `npm_outdated`, `npm_update_all`, `npm_clean`, `yarn_clean`  
**Python**: `py_version`, `pip_list`, `pip_outdated`, `pip_upgrade_all`, `venv_create`, `venv_activate`, `pyserver`  
**Go**: `go_version`, `go_mod_tidy`, `go_test`, `go_build`, `go_install_tools`  
**Ruby**: `ruby_version`, `gem_list`, `gem_outdated`, `bundle_clean`  
**Java**: `java_version`, `mvn_clean`, `mvn_test`, `gradle_clean`  
**Rust**: `rust_version`, `cargo_build`, `cargo_test`, `cargo_clean`, `cargo_update`  
**PHP**: `php_version`, `composer_install`, `composer_update`, `composer_dump`  
**Databases**: `postgres_*`, `mysql_*`, `redis_*`, `mongo_*`  
**Formatting**: `format_json`, `format_xml`, `format_yaml`  
**Linting**: `lint_js`, `lint_py`, `lint_sh`  
**Build**: `make_*`, `cmake_build`  
**Testing**: `test_all`, `coverage_run`, `bench_run`  
**Docs**: `docs_serve`  
**Stats**: `code_stats`  
**Init**: `init_node`, `init_python`, `init_go`, `init_rust`  
**Dependencies**: `deps_install`, `deps_update`  
**Watch**: `watch_test`  
**REPLs**: `repl_node`, `repl_python`, `repl_ruby`, `repl_php`  
**Version Managers**: `nvm_use`, `pyenv_use`, `rbenv_use`  
**API**: `curl_post`, `curl_get`, `curl_put`, `curl_delete`  
**Encoding**: `jwt_decode`, `b64_encode`, `b64_decode`, `url_encode`, `url_decode`  
**Conversion**: `json_pretty`, `yaml2json`, `json2yaml`  
**Random**: `random_string`, `random_number`  
**Color**: `color_test`, `hex2rgb`, `rgb2hex`  
**Math**: `calc`  
**QR**: `qrcode`  
**SSH**: `sshkey`, `sshkey_copy`, `sshkey_gen`, `ssh_tunnel`  
**HTTP**: `http_status`, `download`, `speedtest_cli`

### 08-text-processing.sh (99 functions)
Text manipulation and analysis.

**Case**: `lowercase`, `uppercase`, `titlecase`  
**Manipulation**: `reverse`, `trim`, `dedup`, `remove_empty`  
**Lines**: `add_line_numbers`, `extract_col`, `sort_lines`, `unique_lines`  
**Conversion**: `csv2json`, `json2csv`, `md2html`, `html2md`  
**Sorting**: `sort_by_col`, `sort_numeric`, `sort_reverse`  
**Counting**: `wordcount`, `charcount`, `count_unique`, `count_occurrences`  
**Search**: `grep_lines`, `grep_not`, `extract_between`, `remove_lines`  
**Insert**: `insert_before`, `insert_after`  
**Split**: `split_lines`, `split_size`, `join_files`  
**Diff**: `diff_files`, `diff_side`  
**Format**: `columnize`, `tabulate`  
**View**: `head_n`, `tail_n`, `random_lines`, `shuffle`, `paginate`  
**Wrap**: `wrap`, `indent`, `unindent`, `comment`, `uncomment`  
**Extract**: `extract_emails`, `extract_urls`, `extract_ips`, `extract_phones`  
**Tabs/Spaces**: `tabs2spaces`, `spaces2tabs`  
**Encoding**: `rot13`  
**Analysis**: `char_freq`, `word_freq`, `top_words`, `line_length`, `longest_line`, `shortest_line`, `avg_line_length`  
**Layout**: `concat_lines`, `vertical`, `center_text`, `right_align`, `pad_left`, `pad_right`, `truncate_text`  
**Color**: `strip_colors`, `color_text`, `bold`, `underline`, `italic`, `blink`  
**UI**: `progress_bar`, `spinner`, `box`, `banner`, `cowsay_text`  
**Replace**: `replace_text`, `replace_in_place`  
**Utilities**: `spellcheck`

### 09-cloud-aws.sh (109 functions)
AWS cloud service operations.

**EC2**: `ec2_list`, `ec2_start`, `ec2_stop`, `ec2_terminate`, `ec2_ssh`, `ec2_ip`  
**AMI**: `ami_list`, `ami_create`  
**EBS**: `ebs_volumes`, `ebs_snapshot`  
**S3**: `s3_list`, `s3_mb`, `s3_rb`, `s3_cp`, `s3_sync`, `s3_rm`, `s3_du`, `s3_public`, `s3_website`  
**Lambda**: `lambda_list`, `lambda_invoke`, `lambda_logs`, `lambda_update`  
**DynamoDB**: `dynamo_tables`, `dynamo_scan`, `dynamo_get`, `dynamo_put`  
**RDS**: `rds_list`, `rds_start`, `rds_stop`, `rds_snapshot`  
**CloudFormation**: `cf_list`, `cf_create`, `cf_update`, `cf_delete`, `cf_events`  
**CloudWatch**: `cw_groups`, `cw_tail`, `cw_insights`  
**IAM**: `iam_users`, `iam_roles`, `iam_policies`, `iam_create_user`, `iam_delete_user`  
**ECS**: `ecs_clusters`, `ecs_services`, `ecs_tasks`, `ecs_exec`  
**EKS**: `eks_clusters`, `eks_kubeconfig`, `eks_nodegroups`  
**VPC**: `vpc_list`, `vpc_subnets`  
**Security Groups**: `sg_list`, `sg_rules`  
**Route53**: `r53_zones`, `r53_records`  
**CloudFront**: `cf_distros`, `cf_invalidate`  
**SNS**: `sns_topics`, `sns_publish`  
**SQS**: `sqs_queues`, `sqs_send`, `sqs_receive`, `sqs_purge`  
**ElastiCache**: `elasticache_clusters`  
**Secrets Manager**: `secrets_list`, `secrets_get`, `secrets_create`  
**Systems Manager**: `ssm_parameters`, `ssm_get`, `ssm_put`, `ssm_session`  
**Cost**: `cost_today`, `cost_month`, `aws_billing`  
**Profile**: `aws_profile`, `aws_profiles`, `aws_whoami`, `aws_region`  
**Elastic Beanstalk**: `eb_apps`, `eb_envs`  
**API Gateway**: `apigw_apis`  
**Step Functions**: `sfn_machines`, `sfn_start`

### 10-network.sh (96 functions)
Network diagnostics and management.

**Ping**: `ping_ts`, `ping_until`, `is_up`, `batch_ping`  
**Ports**: `portscan`, `check_port_open`, `check_port`  
**HTTP**: `http_headers`, `http_time`, `http_status_check`, `http_bench`  
**SSL**: `ssl_cert`, `ssl_expiry`  
**DNS**: `whois_lookup`, `reverse_dns`, `dns_all`, `dns_check`, `mx_records`, `txt_records`, `ns_records`, `a_records`, `aaaa_records`, `cname_records`, `dns_servers`, `flush_dns`  
**Trace**: `traceroute_info`, `trace_ts`, `mtr_run`  
**Interfaces**: `net_interfaces`, `interfaces_up`, `interfaces_down`, `interface_up`, `interface_down`  
**Connections**: `net_active`, `conn_count`, `net_listening`, `listening`  
**Stats**: `net_stats`, `bandwidth_monitor`, `net_traffic`  
**Gateway**: `gateway`  
**IP**: `external_ip`, `external_ipv6`, `ip_info`, `geo_ip`  
**Speed**: `download_speed`, `speedtest`, `net_quality`, `jitter_test`, `packet_loss`  
**WiFi**: `wifi_list`, `wifi_connect`, `wifi_current`, `wifi_signal`  
**Routes**: `net_routes`, `add_route`, `del_route`  
**Firewall**: `firewall_status`, `block_ip`, `unblock_ip`  
**Monitor**: `monitor_host`, `latency`  
**TCP**: `tcp_dump`, `capture_packets`  
**Network Info**: `netmask`, `subnet_mask`, `mac_address`, `broadcast`  
**Utilities**: `internet_test`, `url_available`, `wake`, `arp_scan`, `net_reset`

### 11-media.sh (63 functions)
Media file processing and manipulation.

**Images**: `img_convert`, `img_resize`, `img_rotate`, `img_gray`, `img_quality`, `img_batch_convert`, `img_thumb`, `img_watermark`, `img_compress`, `img_size`, `img_info`, `img_slideshow`, `img_ocr`  
**Video**: `vid_to_gif`, `vid_extract_audio`, `vid_to_mp4`, `vid_compress`, `vid_info`, `vid_duration`, `vid_trim`, `vid_merge`, `vid_subtitle`, `vid_remove_audio`, `vid_add_audio`, `vid_screenshot`, `vid_to_frames`, `frames_to_vid`, `vid_speedup`, `vid_slowdown`, `vid_reverse`, `vid_fade`, `vid_thumb`, `vid_resolution`, `vid_fps`, `vid_bitrate`  
**Audio**: `audio_convert`, `audio_normalize`, `audio_volume`, `audio_mono`, `audio_snippet`, `audio_merge`, `audio_bitrate`, `audio_samplerate`, `play_audio`  
**PDF**: `pdf_merge`, `pdf_split`, `pdf_compress`, `pdf_to_img`, `pdf_info`, `pdf_pages`  
**QR**: `qr_create`, `qr_read`  
**Screen**: `screenshot`, `screenrecord`, `webcam_photo`  
**Playback**: `play_video`  
**YouTube**: `yt_download`, `yt_audio`, `yt_playlist`  
**Music**: `spotify_current`, `itunes_current`

## Usage Examples

### Navigation
```bash
mkcd project/src/components  # Create nested dirs and enter
up 3                         # Go up 3 directories
cdgr                         # Jump to git root
bookmark work                # Bookmark current location
goto work                    # Jump to bookmark
```

### File Operations
```bash
extract archive.tar.gz       # Smart extraction
largest 20                   # Show 20 largest files
finddupes                    # Find duplicate files
batch_rename old new         # Batch rename
```

### Git
```bash
gacp "Quick fix"            # Add, commit, push
gundo                       # Undo last commit
gcleanup                    # Clean merged branches
gstats                      # Author statistics
```

### Docker & Kubernetes
```bash
dclean                      # Clean all Docker
kgp                         # Get pods
kex pod-name                # Shell into pod
```

### Development
```bash
test_all                    # Run project tests
code_stats                  # Show statistics
venv_create                 # Python virtualenv
```

### AWS
```bash
ec2_list                    # List instances
s3_sync local/ s3://bucket/ # Sync to S3
lambda_logs func            # Tail logs
```

## Aliases (195 total)

See `bash/aliases/aliases.sh` for the complete list of 195 aliases including:
- Navigation shortcuts (`.`, `..`, `...`)
- List operations (`l`, `la`, `ll`)
- Git shortcuts (`g`, `gst`, `ga`, `gc`)
- Docker shortcuts (`d`, `dc`, `dps`)
- System operations (`c`, `h`, `path`)
- Package managers (`update`, `install`)
- And many more...

## Installation

```bash
# Quick install
./install.sh

# Or manually add to ~/.bashrc:
source /path/to/cbw-dotfiles/bashrc
```

## Help Commands

- `dotfiles_help` - Show help menu
- `dotfiles_count` - Count functions (796)
- `dotfiles_list` - List all functions
- `dotfiles_version` - Show version info
- `dotfiles_update` - Update from git

---

**Total**: 796 functions + 195 aliases = 991+ productivity boosters!
