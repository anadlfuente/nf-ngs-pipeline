#!/usr/bin/env nextflow

//include modules
include { TRIM_GALORE } from './modules/trim_galore.nf'
include { STAR_TWOPASS_1 } from './modules/star_twopass_1.nf'
include { STAR_TWOPASS_GENOME } from './modules/star_twopass_genome.nf'
include { STAR_TWOPASS_2 } from './modules/star_twopass_2.nf'
include { RSeQC_inferexperiment } from './modules/rseqc_inferexperiment.nf'
include { RSeQC_junctionannotation } from './modules/rseqc_junctionann.nf'
include { RSeQC_bamstat } from './modules/rseqc_bamstat.nf'
include { RSeQC_junctionsaturation } from './modules/rseqc_juncsaturation.nf'
include { RSeQC_readduplication } from './modules/rseqc_readdup.nf'
include { RSeQC_readdistribution } from './modules/rseqc_readdist.nf'
include { RSeQC_vainnerdistance } from './modules/rseqc_vainnerdist.nf'
include { GET_STRANDNESS } from './modules/get_strandness.nf'
include { HTSEQ_COUNT } from './modules/htseq_count.nf'

workflow {

    // take:
    //     ch_fasta = Channel.value(params.genome)
    //     ch_gtf = Channel.value(params.gtf)
    //     ch_threads = Channel.value(params.threads)
    //     ch_star_index = Channel.value(params.refDir)
    //     ch_read_length = Channel.value(params.read_length)
    //     ch_pass = Channel.value(params.pass)
    //     ch_maxram = Channel.value(params.maxRAM)
    //     ch_lb = Channel.value(params.LB)
    //     ch_pl = Channel.value(params.PL)

    // Channel for input samples (prepare input for trimming)
    channel.fromPath(params.input_tsv)  // Create channel from input TSV
        .splitCsv(header: false,sep: '\t') // Divide into rows (without header, tab-separated))
        .map { row ->
            def meta = [
                sample: row[0],
                exp: row[3]
            ]
            def fastq1 = file(row[1])
            def fastq2 = file(row[2])
            tuple(meta, fastq1, fastq2) // Transform each row into tuple (metadata, fastq1, fastq2)
        }
        .set { sample_channel } //Save channel in a variable

    //Run Trim galore for trimming adapters and low quality reads
    TRIM_GALORE(sample_channel, params.threads)

    // Run STAR for alignment
    STAR_TWOPASS_1(TRIM_GALORE.out.trim_fastqs,
        file(params.refDir),
        file(params.gtf),
        params.threads
    )

    STAR_TWOPASS_1.out.sj_out.collect().set { all_sj_tabs }
    //Run STAR two pass genome generation
     STAR_TWOPASS_GENOME(
        all_sj_tabs,
        file(params.genome),
        file(params.gtf),
        params.read_length,
        params.threads,
    )

    // Run STAR for alignment
     STAR_TWOPASS_2(
        TRIM_GALORE.out.trim_fastqs,
        STAR_TWOPASS_GENOME.out.twopass_genome_dir,
        file(params.gtf),
        params.read_length,
        params.threads,
        params.PL,
        params.LB,
        params.maxRAM
    )

    // //Run RSeQC for calculate BAM stats
     RSeQC_inferexperiment(
         STAR_TWOPASS_2.out.bam,
         file(params.bed)
     )

     RSeQC_junctionannotation(
         STAR_TWOPASS_2.out.bam,
         file(params.bed)
     )

    RSeQC_bamstat(
         STAR_TWOPASS_2.out.bam,
         file(params.bed)
     )

    RSeQC_junctionsaturation(
         STAR_TWOPASS_2.out.bam,
         file(params.bed)
     )

    RSeQC_vainnerdistance(
         STAR_TWOPASS_2.out.bam,
         file(params.bed)
     )

    RSeQC_readdistribution(
         STAR_TWOPASS_2.out.bam,
         file(params.bed)
     )

    RSeQC_readduplication(
         STAR_TWOPASS_2.out.bam,
         file(params.bed)
     )

    // Get strandness of sample library
    GET_STRANDNESS(
        RSeQC_inferexperiment.out.infer_experiment
    )
    // //Run HTSeq-Count for counting reads mapped to genes
    HTSEQ_COUNT(
        STAR_TWOPASS_2.out.bam,
        GET_STRANDNESS.out.strandness,
        file(params.gtf)
    )

    // // Run MultiQC for aggregating QC results
    // MultiQC(

    // )
}