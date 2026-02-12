#!/usr/bin/env nextflow

//include models
include { TRIM_GALORE } from './modules/trim_galore.nf'
include { STAR_TWOPASS_1 } from './modules/star_twopass_1.nf'

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

    //Run STAR two pass genome generation
    // STAR_TWOPASS_GENOME(
    //     STAR_TWOPASS_1.out.sj_out.collect(),
    //     file(params.genome),
    //     file(params.gtf),
    //     val(params.read_length),
    //     val(params.threads),
    // )

    // Run STAR for alignment
    // STAR_TWOPASS_2(
    //     TRIM_GALORE.out.trim_fastqs,
    //     STAR_TWOPASS_GENOME.out.twopass_genome_dir
    //     file(params.genome),
    //     file(params.gtf),
    //     val(params.read_length),
    //     val(params.threads),
    //     val(params.PL),
    //     val(params.LB),
    //     val(params.maxRAM)
    // )
    // //Run RSeQC for calculate BAM stats
    // RSeQC_BamStats(

    // )

    // //Run HTSeq-Count for counting reads mapped to genes
    // HTSeqCount(
        
    // )

    // // Run MultiQC for aggregating QC results
    // MultiQC(

    // )
   }