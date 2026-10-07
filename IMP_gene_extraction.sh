#!/bin/bash
(
set -euo pipefail
shopt -s nullglob

mkdir -p IMP_regions
printf 'sample\tstatus\tIMP_hits\n' > IMP_regions/summary.tsv

for gff in Bakta/*/*.gff3; do
    sample=$(basename "$gff" .gff3)
    fasta="${gff%.gff3}.fna"
    out="IMP_regions/$sample"

    if [[ ! -s "$fasta" ]]; then
        printf '%s\tmissing_FASTA\tNA\n' "$sample" \
            >> IMP_regions/summary.tsv
        continue
    fi

    mkdir -p "$out"

    # Locate IMP CDS features and convert GFF coordinates to BED.
    awk -F '\t' -v OFS='\t' -v sample="$sample" '
        /^##FASTA/ {exit}
        /^#/ {next}
        $3 == "CDS" &&
        tolower($9) ~ /(^|[^a-z0-9])blaimp([_-]?[0-9]+)?([^a-z0-9]|$)|(^|[^a-z0-9])imp-[0-9]+([^a-z0-9]|$)/ {
            print $1, $4-1, $5, sample "_IMP_" ++n, 0, $7
        }
    ' "$gff" > "$out/IMP.bed"

    hits=$(wc -l < "$out/IMP.bed")

    if [[ "$hits" -eq 0 ]]; then
        printf '%s\tno_annotated_IMP\t0\n' "$sample" \
            >> IMP_regions/summary.tsv
        continue
    fi

    samtools faidx "$fasta"

    # Extract the IMP gene itself.
    bedtools getfasta \
        -fi "$fasta" -bed "$out/IMP.bed" \
        -s -name > "$out/IMP_gene.fasta"

    # Extend each region by 20 kb on both sides.
    bedtools slop \
        -i "$out/IMP.bed" -g "${fasta}.fai" \
        -b 20000 > "$out/IMP_20kb.bed"

    # Extract the surrounding sequence.
    bedtools getfasta \
        -fi "$fasta" -bed "$out/IMP_20kb.bed" \
        -s -name > "$out/IMP_20kb.fasta"

    printf '%s\textracted\t%s\n' "$sample" "$hits" \
        >> IMP_regions/summary.tsv

    echo "$sample: extracted $hits IMP region(s)"
done
)
