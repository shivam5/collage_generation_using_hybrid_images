% Takes in the directory address as an argument and will output the
% resultant collage as collage.jpg
function return_image = Collage_Wrapper_2015CSB1032( directory_address )
    % Reads all the .jpg files from that directory    
    imagefiles = dir([directory_address,'*.jpg']);
    % Calculate number of files
    nfiles = length(imagefiles);
    
    % For all files
    for i=1:nfiles
       % Load the image in images{i}
       currentfilename = strcat(directory_address, imagefiles(i).name);
       currentimage = imread(currentfilename);
       images{i} = currentimage;
    end
    
    % If there were no files, then return
    if (nfiles == 0)
        disp('No images read');
        return_image = [];
        return;
    end
    
    % For hundred iterations the loop will run, and a binary tree (which is mapped to 
    % the final collage structure) will be generated until the aspect ratio
    % is between 0.8 and 1.8. The idea of building the tree is described in
    % the report.
    for i=1:100
        root = recursively_build_tree(1, nfiles, images, imagefiles, TreeNode.empty);
        root.ar = recur_calc_ar(root);
        root.width = 800;
        root.height = floor(root.width/root.ar);
        root.x = 0;
        root.y = 0;
        if (root.ar>0.8 && root.ar<1.8)
            break;
        end
    end
    
    % Boxes store the position information for each image
    boxes = [];
    boxes = recur_calc_pos(root, boxes);
    % Initializing the new image
    newimage = zeros(root.height, root.width, 3, 'uint8');
    
    % Scaling up by a factor of 0.06
    for i=1:nfiles
        width = boxes(i,3) - boxes(i,1)+1;
        height = boxes(i,4) - boxes(i,2)+1;
        offset_w = 0.06*width;
        offset_h = 0.06*height;
        boxes(i,1) = floor(max(1, boxes(i,1)-offset_w));
        boxes(i,3) = floor(min(root.width, boxes(i,3)+offset_w));    
        boxes(i,2) = floor(max(1, boxes(i,2)-offset_h));
        boxes(i,4) = floor(min(root.height, boxes(i,4)+offset_h));    
    end
    
    % Maintaining a 2-D array containing information of all the overlapping
    % area
    global_intersection_area = zeros(root.height, root.width);
    
    
    for i=1:nfiles
        % Resizing all images as dictated by the binary tree structure
        resizedimages{i} = imresize(images{i}, [ boxes(i,4)-boxes(i,2)+1 boxes(i,3)-boxes(i,1)+1 ]);
        
        % Tapering edges
        PSF = fspecial('gaussian');
        resizedimages{i} = edgetaper(resizedimages{i},PSF);
        
        % Initializing intersection_area by all zeros
        intersection_area = zeros(root.height, root.width);
        
        % If there is a overlap between the currently formed image and the
        % new image we are placing, make the respective location in
        % intersection_area to be 1.
        for ii=1:root.height
            for jj=1:root.width
                if ( (newimage(ii,jj,1)~=0) && (newimage(ii,jj,2)~=0) && (newimage(ii,jj,3)~=0) && (ii>=boxes(i,2)) && (ii<=boxes(i,4)) && (jj>=boxes(i,1)) && (jj<=boxes(i,3))  )
                    intersection_area(ii,jj)=1;
                end
            end
        end
                    
        newimage = CreateHybridImage_2015CSB1032(newimage, [], resizedimages{i}, [], intersection_area, boxes(i,:) );            
    
        % Maintaing the global intersection area
        for ii=1:root.height
            for jj=1:root.width
                if ( intersection_area(ii,jj)==1 )
                        global_intersection_area(ii,jj) = 1;                
                end
            end
        end
 
    end
    
    % Dilating the global intersection area
    global_intersection_area = imdilate(global_intersection_area,strel('disk',1));
    
    % Applying average filter to the overlapped region of interest
    h = fspecial('average');
    newimage(:,:,1) = roifilt2(h,newimage(:,:,1),global_intersection_area);
    newimage(:,:,2) = roifilt2(h,newimage(:,:,2),global_intersection_area);
    newimage(:,:,3) = roifilt2(h,newimage(:,:,3),global_intersection_area);
     
    % Saving the image
    imshow(newimage);
    imwrite(newimage, 'collage.jpg');
    return_image = newimage;
    return;
end

