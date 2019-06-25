#!/bin/bash
#2017/12/28 edit for YY3.1 test

cat read_ata* | grep sd | cut -f 1 -d ":" >> list_seq_r.txt

cat read_ata* | grep read: | cut -f 2 -d "(" | cut -f 1 -d "M" >> list_seq_r.txt

cat write_ata* | grep sd | cut -f 1 -d ":" >> list_seq_w.txt

cat write_ata* | grep write: | cut -f 2 -d "(" | cut -f 1 -d "M" >> list_seq_w.txt

#cat randr_ata* | grep sd | cut -f 1 -d ":" >> list_rand_r.txt

#cat randr_ata* | grep read\ | cut -f 4 -d "=" | cut -f 1 -d "," >> list_rand_r.txt

#cat randw_ata* | grep sd | cut -f 1 -d ":" >> list_rand_w.txt

#cat randw_ata* | grep write: | cut -f 4 -d "=" | cut -f 1 -d "," >> list_rand_w.txt


