
workflow {


    // Channel for input samples (prepare input for trimming)
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

    // Channel to count number of samples per experiment
    channel.fromPath(params.input_csv)
        .splitCsv(header: false, sep: '\t')
        .map { row ->
            def exp = row[3]
            tuple(exp, row[0])  // (experimento, nombre_muestra)
        }
        .groupTuple(by: 0)  // group by experiment
        .map { exp, samples ->
            tuple(exp, samples.size())  // emit (exp, sample_count)
        }
        .set { exp_sample_counts } // exit [(exp,num_counts), ...]
    
    //Run Trim galore for trimming adapters and low quality reads
    TRIM_GALORE(sample_channel)

    // Run STAR for alignment
    STAR_TWOPASS_1(TRIM_GALORE.out.trim_fastqs,
        file(params.refDir),
        file(params.gtf)
    )

    STAR_TWOPASS_1.out.sj_out
        .groupTuple(by: 0)       // agrupa por experimento
        .join(exp_sample_counts) // (exp, [sj_outs]) join con (exp, count)
        .map { exp, sj_outs, count ->
            // Aseguramos que llegaron todas las muestras
            if (sj_outs.size() == count) {
                tuple(exp, sj_outs)
            } else {
                null // no pasa nada hasta que estén todas
            }
        }
        .filter { it != null }
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