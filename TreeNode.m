classdef TreeNode < handle

    properties
        split
        ar
        height
        width
        x
        y
        l_child = TreeNode.empty
        r_child = TreeNode.empty
        parent = TreeNode.empty
    end
    
    methods
        function node = TreeNode(split)
            if (nargin > 0)
                node.split = split;
            end
        end
        
        function node = recursively_build_tree (low, high, images, imagefiles, root)
            if (high<low)
                node = TreeNode.empty;
                return;
            elseif (low==high)
                node = TreeNode(imagefiles(low).name);
                node.parent = root;
                [rows, cols, channels] = size(images{low});
                node.ar = cols/rows;
                node.height = rows;
                node.width = cols;
                return;
            else
                % Generate a random number, check if it is less than 0.5
                % then H, else V
                r = rand();
                if (r<0.5)
                    node = TreeNode('H');
                else
                    node = TreeNode('V');
                end
                node.parent = root;
                mid = (low+high)/2;
                mid = floor(mid);
                node.l_child = recursively_build_tree (low, mid, images, imagefiles, node);
                node.r_child = recursively_build_tree (mid+1, high, images, imagefiles, node);
                return;
            end
            return;
        end
        
        function a = recur_calc_ar(node)
            if ( ( isempty(node.l_child) ) && ( isempty(node.r_child) ) )
                a = node.ar;
            else
                ar_left = recur_calc_ar(node.l_child);
                ar_right = recur_calc_ar(node.r_child);
                if (node.split == 'V')
                    node.ar = ar_left + ar_right;
                else
                    node.ar = (ar_left*ar_right)/(ar_left + ar_right);
                end
            end
            a = node.ar;
            return;
        end
        
        function boxes = recur_calc_pos(node, boxes)
            if ( isempty(node) )
                return;
            elseif ( ~isempty(node.parent) )
                top_down_calc_pos(node);                
            end
            if ( ( isempty(node.l_child) ) && ( isempty(node.r_child) ) )
                B = [ floor(node.x)+1 floor(node.y)+1 floor(node.x+node.width) floor(node.y+node.height) ];
                boxes = [boxes; B];
            end
            boxes = recur_calc_pos(node.l_child, boxes);
            boxes = recur_calc_pos(node.r_child, boxes);
            return;
        end
        
        function top_down_calc_pos(node)
            if (node.parent.split == 'V')
                node.height = node.parent.height;
                node.width = node.height * node.ar;
            else
                node.width = node.parent.width;
                node.height = node.width/node.ar;
            end
            
            if (node.parent.l_child == node)
                node.x = node.parent.x;
                node.y = node.parent.y;
            else
                if (node.parent.split == 'V')
                    node.x = node.parent.x + node.parent.width - node.width;
                    node.y = node.parent.y;
                else
                    node.y = node.parent.y + node.parent.height - node.height;
                    node.x = node.parent.x;
                end
            end            
        end
        
    end
    
end

