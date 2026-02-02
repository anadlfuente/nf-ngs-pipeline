
workflow {


    // Channel for input samples
    channel.fromPath(params.input_csv)
        .splitCsv(header: false,sep: '\t')
        .map { row ->
            def meta = [
                sample: row[0]
                exp: row[3]
            ]
            def fastq1 = file(row[1])
            def fastq2 = file(row[2])
            tuple(meta, fastq1, fastq2)
        }
        .set { sample_channel }

    
    //Run Trim galore for trimming adapters and low quality reads
    TRIM_GALORE(sample_channel)

    // Run STAR for alignment
    STAR_TWOPASS_1(TRIM_GALORE.out.trim_fastqs,
        file(params.refDir),

    )

    // Group all SJ out files for star two pass genome generation
    channel.fromPath("${params.outdir}/NGSalign_output/STAR/Pass1/*/*.SJ.out.tab")
        .map { file ->
            def exp = file.getParent().getName()
            tuple(exp, file)
        }
        .groupTuple(by: 0) // group SJ.out.tab per experiment
        .set { sj_outs_channel_exp }

    //Run STAR two pass genome generation
    STAR_TWOPASS_GENOME(
        sj_out_channel_exp
    )

    // Run STAR for alignment
    STAR_TWOPASS_2(
        
    )
    //Run RSeQC for calculate BAM stats
    RSeQC_BamStats(

    )

    //Run HTSeq-Count for counting reads mapped to genes
    HTSeqCount(
        
    )

    // Run MultiQC for aggregating QC results
    MultiQC(

    )
}