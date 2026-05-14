#!/bin/bash

# Usage example:
# ./fmri_distortion_correction.sh \
#   /mnt/g/project/func/epi.nii.gz \
#   /mnt/g/project/fmap/mag1.nii.gz \
#   /mnt/g/project/fmap/mag2.nii.gz \
#   /mnt/g/project/fmap/phase.nii.gz \
#   /mnt/g/project/anat/t1.nii.gz \
#   0.000540003 \
#   0.00246 \
#   j-

FUNC_EPI="$1"      # Functional EPI image
FMAP_MAG1="$2"     # Fieldmap magnitude1 image
FMAP_MAG2="$3"     # Fieldmap magnitude2 image
FMAP_PHASE="$4"    # Fieldmap phase difference image
T1_IMAGE="$5"      # T1-weighted structural image (optional for later registration)
EPI_DWELL="$6"     # Dwell time (effective echo spacing, seconds)
DELTA_TE="$7"      # Phase echo time difference (seconds)
PHASE_DIR="$8"     # Phase encoding direction ("j-" for y-, "j+" for y+)

# Output directories
OUT_DIR=$(dirname "$FUNC_EPI")
mkdir -p "$OUT_DIR/fmap_corr"

echo "Skull-stripping magnitude image..."
bet "$FMAP_MAG1" "$OUT_DIR/fmap_corr/magnitude1_brain.nii.gz" -f 0.5 -g 0
fslmaths "$OUT_DIR/fmap_corr/magnitude1_brain.nii.gz" -ero "$OUT_DIR/fmap_corr/magnitude1_brain_ero.nii.gz"

echo "Preparing fieldmap (rad/s)..."
fsl_prepare_fieldmap SIEMENS \
    "$FMAP_PHASE" \
    "$OUT_DIR/fmap_corr/magnitude1_brain_ero.nii.gz" \
    "$OUT_DIR/fmap_corr/fmap_rads.nii.gz" \
    $(echo $DELTA_TE | awk '{printf "%.2f", $1*1000}') # delta TE in ms

# Determine FSL unwarpdir
if [ "$PHASE_DIR" == "j-" ]; then
    UNWARPDIR="y-"
elif [ "$PHASE_DIR" == "j+" ]; then
    UNWARPDIR="y"
else
    echo "Unknown phase encoding direction, defaulting to y-"; UNWARPDIR="y-"
fi

echo "Applying distortion correction with FUGUE..."
fugue -i "$FUNC_EPI" \
      --dwell="$EPI_DWELL" \
      --loadfmap="$OUT_DIR/fmap_corr/fmap_rads.nii.gz" \
      --unwarpdir=$UNWARPDIR \
      -u "$OUT_DIR/fmap_corr/$(basename ${FUNC_EPI%.nii.gz})_unwarped.nii.gz"

echo "Distortion correction complete!"
echo "Output: $OUT_DIR/fmap_corr/$(basename ${FUNC_EPI%.nii.gz})_unwarped.nii.gz"
