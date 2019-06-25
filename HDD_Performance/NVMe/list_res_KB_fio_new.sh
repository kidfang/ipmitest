#!/bin/bash
#2017/12/28 edit for YY3.1 test

cat read_* | grep nvme | cut -f 1 -d ":" >> list_seq_r.txt

cat read_* | grep READ: | cut -f 2 -d "=" | cut -f 2 -d "M" | cut -f 2 -d "(" >> list_seq_r.txt

cat write_* | grep nvme | cut -f 1 -d ":" >> list_seq_w.txt

cat write_* | grep WRITE: | cut -f 2 -d "=" | cut -f 2 -d "M" | cut -f 2 -d "(" >> list_seq_w.txt

#cat randr_nvme* | grep nvme | cut -f 1 -d ":" >> list_rand_r.txt

#cat randr_nvme* | grep read\ | cut -f 4 -d "=" | cut -f 1 -d "," >> list_rand_r.txt

#cat randw_nvme* | grep nvme | cut -f 1 -d ":" >> list_rand_w.txt

#cat randw_nvme* | grep write: | cut -f 4 -d "=" | cut -f 1 -d "," >> list_rand_w.txt


