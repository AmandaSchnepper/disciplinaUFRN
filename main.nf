// Declare syntax version
nextflow.enable.dsl=2

// Script parameters
params.genes = "$projectDir/data_sc/R02_genes_S288C.bed"
params.lens = "$projectDir/data_sc/R01_chr_lens_S288C.tsv"
params.genome = "$projectDir/data_sc/S288C.fasta"
params.outdir = "results"

process bedtools_flank {
  publishDir params.outdir, mode:'copy'

  input:
    path path_genes
    path path_lens

  output:
    path "flanking.bed"

    """
    bedtools flank -i ${path_genes} -g ${path_lens} -l 1500 -r 0 -s > flanking.bed
    """
}

process bedtools_getfasta {
  publishDir params.outdir, mode:'copy'

  input:
    path flanking
    path genomefasta

  output:
    path "promoters.fasta"

    """
    bedtools getfasta -fi ${genomefasta} -nameOnly -bed ${flanking} -fo promoters.fasta
    """
}

workflow {
   promoter_regions = bedtools_flank(params.genes, params.lens) 
   bedtools_getfasta(promoter_regions ,params.genome)
}

workflow.onComplete {
    log.info ( workflow.success ? "\nDone!" : "Oops .. something went wrong" )
}
