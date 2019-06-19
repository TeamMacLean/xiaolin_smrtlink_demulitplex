#!/bin/bash

source smrtlink-6.0

outdir=CCS_demultiplex

srun dataset create --force --type SubreadSet --name xiaolin --generateIndices sequeldata.subreadset.xml input.fofn
srun dataset create --force --type BarcodeSet --name barcodes --generateIndices singleBarcoding.barcodeset.xml barcodes.fasta
srun pbsmrtpipe pipeline-id -o ${outdir}  -e "eid_subread:sequeldata.subreadset.xml" -e "eid_barcode:singleBarcoding.barcodeset.xml" --preset-xml ./hpc_preset.xml --preset-xml ./sa3_ds_ccs_barcode_taskoptions.xml --debug pbsmrtpipe.pipelines.sa3_ds_ccs_barcode

# the pipeline fails at lima step, with error to provide same or different barcode. so do the following

srun lima --same  --ccs --split-bam-named ${outdir}/tasks/pbcoretools.tasks.gather_ccsset-1/file.consensusreadset.xml singleBarcoding.barcodeset.xml CCS_same.bam
srun lima --different --ccs --split-bam-named ${outdir}/tasks/pbcoretools.tasks.gather_ccsset-1/file.consensusreadset.xml singleBarcoding.barcodeset.xml CCS_different.bam
for bam in *.bam; do
	prefix=$(echo $bam | sed 's/.bam$//')
	bam2fastq -o $prefix  $bam
done

