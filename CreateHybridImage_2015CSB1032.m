function fused_hybrid_image = CreateHybridImage_2015CSB1032( Image1, bb1, Image2, bb2, intersection_area, placement )
    
    % If the call is of the default format containing 4 arguments
    if ~exist('intersection_area','var')
        if (bb1(3)-bb1(1) ~= bb2(3)-bb2(1))
            disp('Height of bounding boxes not same');
            return;
        end
        if (bb1(2)<bb2(2))
            disp('Image1 should be one the left and Image2 on the right');
            return;
        end
        [x, y, z] = size(Image1);
        [x1, y1, z1] = size(Image2);
        width = y + y1 - (bb1(2)-bb1(4));
        
        % Intializing new image as blank
        newimage = [];
        % Concatenating from 1st image
        newimage = [newimage, Image1(1:bb1(3), 1:bb1(2)-1, :)];
        
        % Setting the center for gaussian distribution
        centerI = ceil (x/2);
        centerJ = ceil( width /2);

        % Inititializing the overlap part
        centerpart = zeros(bb1(3)-bb1(1)+1, bb1(4)-bb1(2)+1, 3);
        % Weighted addition for the overlap part. The weight is being taken
        % from the gaussian distribution given below whose center is set
        % above.
        for ii=1:bb1(3)-bb1(1)+1
            for jj=1:bb1(4)-bb1(2)+1
                for kk=1:3
                    weight = exp(-1 * ((ii - centerI)^2 + (jj - centerJ)^2) / (centerI^2+centerJ^2));
                    centerpart(ii,jj,kk) =  weight*Image1(bb1(1)+ii-1, bb1(2)+jj-1,kk) + (1-weight)*Image2(bb2(1)+ii-1, bb2(2)+jj-1,kk);
                end
            end
        end
        % Concatenating the center part in the newimage
        newimage = [newimage, centerpart];
        [r,c,ch] = size(Image2);
        % Concatenating the Image2 part
        newimage = [newimage, Image2(1:bb2(3), bb2(4):c, :)];
        fused_hybrid_image = newimage;
        return;
        
    % More generalized call, when intersection_area is passed
    else
        [rows, cols, chans] = size(Image1);
        fused_hybrid_image = zeros(rows, cols, chans, 'uint8');
        [rows1, cols1, chans1] = size(Image2);
        % Setting center for gaussian distribution
        centerI = ceil(rows1/2);
        centerJ = ceil(cols1/2);
        
        % Iterating through the image
        for ii=1:rows
            for jj=1:cols
                for kk=1:3
                    % If not an overlap area
                    if (intersection_area(ii,jj) == 0)
                        % If a coordinate which is supposed to be of image
                        % 2, use pixel information of image2
                        if ( (ii>=placement(2)) && (ii<=placement(4)) && (jj>=placement(1)) && (jj<=placement(3)) )
                            fused_hybrid_image(ii,jj,kk) = Image2(ii-placement(2)+1, jj-placement(1)+1, kk);
                        % Otherwise use pixel information of image1
                        else
                            fused_hybrid_image(ii,jj,kk) = Image1(ii,jj,kk);
                        end
                        
                    % Weighted addition for the overlap part. The weight is being taken
                    % from the gaussian distribution given below whose center is set
                    % above.
                    else
                        weight = exp(-1.0 * ((ii - centerI)^2 + (jj - centerJ)^2) / (centerI^2+centerJ^2));
                        weight = max(0.3, weight);
                        fused_hybrid_image(ii,jj,kk) =  weight*Image1(ii,jj,kk) + (1-weight)*Image2(ii-placement(2)+1, jj-placement(1)+1, kk);
                end
            end
        end
        
    end


end

