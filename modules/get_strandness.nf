process GET_STRANDNESS {
    tag "${meta.sample}"

    conda '/data/programs/mambaforge/envs/NGSalign'

    input:
    tuple val(meta), path(infer_experiment)
    

    output:
    tuple val(meta), path('strandness.txt'), emit: strandness

    script:
    """

	forward=\$(grep "1++,1--,2+-,2-+" ${infer_experiment} | awk '{print \$(NF)*100}') #Convert to % as bash doesn't read decimals
	if [ "\${forward%.*}" -gt 75 ];then #Greater than 75%, fwd; fewer than 25%, rev
		echo "yes" > strandness.txt
	elif [ "\${forward%.*}" -lt 25 ];then
		echo "reverse" > strandness.txt
	else
		echo "no" > strandness.txt
	fi

    """
}