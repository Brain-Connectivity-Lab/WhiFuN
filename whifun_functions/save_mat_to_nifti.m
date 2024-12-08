function save_mat_to_nifti(T1_image_temp,image,output)
[T1_image,T1_head] = y_Read(T1_image_temp);
y_Write(image,T1_head,output);
end

