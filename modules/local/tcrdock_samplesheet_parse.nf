process TCRDOCK_SAMPLESHEET_PARSE {
    tag "$samplesheet"
    label 'process_single'

    publishDir path: "$params.outdir/$params.mode/batches", mode: "copy", saveAs: { filename -> filename.equals('versions.yml') ? null : filename }

    def PANDAS_VERSION = '1.4.3'
    conda "conda-forge::pandas=$PANDAS_VERSION"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'oras://community.wave.seqera.io/library/pandas:2.2.3--9b034ee33172d809' :
        'community.wave.seqera.io/library/pandas:2.2.3--9b034ee33172d809' }"

    input:
    path samplesheet

    output:
    path '*.tsv'       , emit: tsvs
    path "versions.yml", emit: versions

    when:
    task.ext.when == null || task.ext.when

    script: // This script is bundled with the pipeline, in nf-core/proteinfold/bin/
    def batch_size = params.batch_size ?: 10
    """
    tcrdock_parse_samplesheet.py \\
        $samplesheet \\
        $batch_size

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        python: \$(python --version | sed 's/Python //g')
        pandas: $PANDAS_VERSION
    END_VERSIONS
    """
}
