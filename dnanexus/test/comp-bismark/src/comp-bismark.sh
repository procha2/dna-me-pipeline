#!/bin/bash
# comp-star-bismark 0.0.1
# Generated by dx-app-wizard.
#
# Basic execution pattern: Your app will run on a single machine from
# beginning to end.
#
# Your job's input variables (if any) will be loaded as environment
# variables before this script runs.  Any array inputs will be loaded
# as bash arrays.
#
# Any code outside of main() (or any entry point you may add) is
# ALWAYS executed, followed by running the entry point itself.
#
# See https://wiki.dnanexus.com/Developer-Portal for tutorials on how
# to modify this file.

set -x
set +e

main() {
    echo "Value of test dataset: '$test_dir'"
    echo "Value of standard dataset: '$data_dir'"

    # The following line(s) use the dx command-line tool to download your file
    # inputs to the local file system using variable names for the filenames. To
    # recover the original filenames, you can use the output of "dx describe"
    # "$variable" --name".

    mkdir test_files
    mkdir data_files

    (unset DX_WORKSPACE_ID DX_PROJECT_CONTEXT_ID; \
        dx select project-BKf7zV80z53QbqKQz18005vZ; \
        dx download /"$data_dir"/* -f -r -o data_files)

    (unset DX_WORKSPACE_ID DX_PROJECT_CONTEXT_ID; \
        dx select project-BKf7zV80z53QbqKQz18005vZ; \
        dx download /"$test_dir"/* -f -r -o test_files)
    bunzip2 test_files/output/*sam*.bz2
    cat test_files/output/*.sam* > test_files/test.sam

    # Fill in your application code here.
    #
    # To report any recognized errors in the correct format in
    # $HOME/job_error.json and exit this script, you can use the
    # dx-jobutil-report-error utility as follows:
    #
    #   dx-jobutil-report-error "My error message"
    #
    # Note however that this entire bash script is executed with -e
    # when running in the cloud, so any line which returns a nonzero
    # exit code will prematurely exit the script; if no error was
    # reported in the job_error.json file, then the failure reason
    # will be AppInternalError with a generic error message.
    find
    echo "convert SAM->BAM"
    echo "test"
    /usr/bin/samtools view -Sb test_files/test.sam > test.bam
    echo "data"
    /usr/bin/samtools view -Sb data_files/*.sam > data.bam

    echo "sort BAMs"
    echo "test"
    /usr/bin/samtools sort -@ 4 test.bam testSorted
    echo "data"
    /usr/bin/samtools sort -@ 4 data.bam dataSorted


    `ls -l1 *.bam`
    echo "Bamutils Diff"
    /usr/bin/bam diff --recPoolSize 10000000 --in1 testSorted.bam --in2 dataSorted.bam > bam_diff


    # don't worry about bigwigs for now
    #for ii in `cd $data_dir; ls *bw`
    #do
    #    echo $ii
    #    diff $data_dir/$ii $2/$ii | head
    #done

    # The following line(s) use the dx command-line tool to upload your file
    # outputs after you have created them on the local file system.  It assumes
    # that you have used the output field name for the filename for each output,
    # but you can change that behavior to suit your needs.  Run "dx upload -h"
    # to see more options to set metadata.
    #log_diff=$(dx upload log_diff --brief)
    bam_diff=$(dx upload bam_diff --brief)
    #isoform_quant_diff=$(dx upload isoform_quant_diff --brief)
    #gene_quant_diff=$(dx upload gene_quant_diff --brief)

    # The following line(s) use the utility dx-jobutil-add-output to format and
    # add output variables to your job's output as appropriate for the output
    # class.  Run "dx-jobutil-add-output -h" for more information on what it
    # does.

    #dx-jobutil-add-output log_diff "$log_diff" --class=file
    dx-jobutil-add-output bam_diff "$bam_diff" --class=file
    #dx-jobutil-add-output isoform_quant_diff "$isoform_quant_diff" --class=file
    #dx-jobutil-add-output gene_quant_diff "$gene_quant_diff" --class=file
    #dx-jobutil-add-output bigwig_diff "true" --class=boolean
}