# IO Benchmark: fio

## Installation
RHEL 7.3

```sh
# yum install -y fio
# fio --version
fio-2.2.8
```

## [Examples](https://www.linux.com/learn/inspecting-disk-io-performance-fio)

```sh
# cat ./random-read-test.fio 
; random read of 128mb of data

[random-read]
rw=randread
size=128m
directory=/mydata


# fio ./random-read-test.fio 
random-read: (g=0): rw=randread, bs=4K-4K/4K-4K/4K-4K, ioengine=sync, iodepth=1
fio-2.2.8
Starting 1 process
random-read: Laying out IO file(s) (1 file(s) / 128MB)
Jobs: 1 (f=1): [r(1)] [100.0% done] [12252KB/0KB/0KB /s] [3063/0/0 iops] [eta 00m:00s]
random-read: (groupid=0, jobs=1): err= 0: pid=2394: Tue Aug 29 17:10:13 2017
  read : io=131072KB, bw=13499KB/s, iops=3374, runt=  9710msec
    clat (usec): min=170, max=8729, avg=294.78, stdev=160.37
     lat (usec): min=170, max=8729, avg=295.00, stdev=160.37
    clat percentiles (usec):
     |  1.00th=[  195],  5.00th=[  205], 10.00th=[  211], 20.00th=[  221],
     | 30.00th=[  233], 40.00th=[  282], 50.00th=[  310], 60.00th=[  318],
     | 70.00th=[  326], 80.00th=[  334], 90.00th=[  342], 95.00th=[  354],
     | 99.00th=[  498], 99.50th=[  748], 99.90th=[ 2640], 99.95th=[ 3440],
     | 99.99th=[ 6240]
    bw (KB  /s): min=12208, max=17856, per=100.00%, avg=13530.53, stdev=2144.74
    lat (usec) : 250=36.03%, 500=62.98%, 750=0.50%, 1000=0.16%
    lat (msec) : 2=0.20%, 4=0.09%, 10=0.04%
  cpu          : usr=0.47%, sys=4.29%, ctx=32770, majf=0, minf=32
  IO depths    : 1=100.0%, 2=0.0%, 4=0.0%, 8=0.0%, 16=0.0%, 32=0.0%, >=64=0.0%
     submit    : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     complete  : 0=0.0%, 4=100.0%, 8=0.0%, 16=0.0%, 32=0.0%, 64=0.0%, >=64=0.0%
     issued    : total=r=32768/w=0/d=0, short=r=0/w=0/d=0, drop=r=0/w=0/d=0
     latency   : target=0, window=0, percentile=100.00%, depth=1

Run status group 0 (all jobs):
   READ: io=131072KB, aggrb=13498KB/s, minb=13498KB/s, maxb=13498KB/s, mint=9710msec, maxt=9710msec

Disk stats (read/write):
  xvda: ios=32548/0, merge=0/0, ticks=9434/0, in_queue=9434, util=96.97%
```

The Bigger <code>bw</code> and the smaller <code>lat</code>, the better.

## Reference

[1]. [fio-howto](https://github.com/axboe/fio/blob/master/HOWTO) and [pdf version](https://media.readthedocs.org/pdf/fio/latest/fio.pdf)

[2]. [ipos wiki]() and [ipos, throughput, and latency](http://searchsolidstatestorage.techtarget.com/definition/IOPS-Input-Output-Operations-Per-Second)
