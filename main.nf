
workflow {

    take:
        ch_fasta = Channel.value(params.genome)
        ch_gtf = Channel.value(params.gtf)
        ch_threads = Channel.value(params.threads)
        ch_star_index = Channel.value(params.refDir)
        ch_read_length = Channel.value(params.read_length)
        ch_pass = Channel.value(params.pass)
        ch_maxram = Channel.value(params.maxRAM)
        ch_lb = Channel.value(params.LB)
        ch_pl = Channel.value(params.PL)

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
        file(params.gtf),
        val(params.threads)
    )

    // Prepare SJ.out.tab per experiment for genome generation
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
        sj_outs_channel_exp,
        file(params.genome),
        file(params.gtf),
        val(params.read_length),
        val(params.threads),
    )

    // Relate experiment genome with sample for alignment step
    TRIM_GALORE.out.trim_fastqs
        .map { meta, fastq1, fastq2 ->
            tuple(meta.exp, meta, fastq1, fastq2) // Add experiment as key
        }.join (STAR_TWOPASS_GENOME.out.twopass_genome_dir)
        .map { exp, sample_data, genome_dir ->
            def (meta, fastq1, fastq2) = sample_data
            tuple(meta, fastq1, fastq2, genome_dir)
        }
        .set { star_passtwo_alignment_input }

    // Run STAR for alignment
    STAR_TWOPASS_2(
        star_passtwo_alignment_input,
        file(params.genome),
        file(params.gtf),
        val(params.read_length),
        val(params.threads),
        val(params.PL),
        val(params.LB),
        val(params.maxRAM)
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