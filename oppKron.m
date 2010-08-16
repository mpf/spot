classdef oppKron<opKron
    
    methods
        function y=oppKron(varargin)
            y=y@opKron(varargin);
        end
    end
    
    methods(Access = protected)
        
        function y=multiply(op,x,mode)
            pool_size=matlabpool('size');
            if pool_size == 0
                y=multiply@opKron(op,x,mode);
            else
                slice_length=floor(size(x,2)/pool_size);
                overhead=size(x,2)-pool_size*slice_length; %Number of
                %additionnal columns to add to the last slice of x.
                
                if slice_length == 0 %Case where the number of labs is
                    %inferior to the width of x
                    spmd
                        x_replicated=x;
                        op_replicated=op;
                        if labindex<=size(x_replicated,2)
                            y=spot_multiply(op_replicated,...
                                x_replicated(:,labindex),mode);
                        end
                    end
                else
                    spmd
                        x_replicated=x;
                        op_replicated=op;
                        
                        if labindex<pool_size
                            y=spot_multiply(op_replicated,x_replicated(:,(labindex-1)*...
                                slice_length+1:labindex*slice_length),mode);
                        else
                            y=spot_multiply(op_replicated,x_replicated(:,(labindex-1)*...
                                slice_length+1:labindex*slice_length+overhead),mode);
                        end
                    end
                    y=[y{1} y{2}];
                end
            end
        end
    end
end