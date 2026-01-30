



workflow {


    // Channel for input samples
    channel.fromPath(params.input_csv)
        .splitCsv(header: true)
        .map { row ->
            def meta = [
                sample: row.sample
            ]
            def fasta = file(row.fasta_path)
            [meta, fasta]
        }
        .set { sample_channel }

    
    //Run Trim galore for trimming adapters and low quality reads
    TrimGalore(

    )

    // Run STAR for alignment
    STAR(
        
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