classdef opKron < opSpot & opSweep
    %Kronecker tensor product
    %
    %opKron(OP1,OP2,...OPn) creates an operator that is the Kronecker
    %tensor product of OP1, OP2, ..., OPn.
    
    %   Copyright 2009, Rayan Saab, Ewout van den Berg and Michael P. Friedlander
    %   See the file COPYING.txt for full copyright information.
    %   Use the command 'spot.gpl' to locate this file.
    
    %   http://www.cs.ubc.ca/labs/scl/spot
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Properties
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    properties
        permutation; % Define the order to use when applying the operators
        %of the Kronecker product on a data vector
    end
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Public methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    methods
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Constructor
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function op = opKron(varargin)
            narg=nargin;
            
            %Test the case where varargin is a list
            if narg == 1
                narg=length(varargin{1});
                varargin=varargin{1};
            end
            
            if narg < 2
                error('At least two operators must be specified')
            end
            
            % Input matrices are immediately cast to opMatrix.
            for i=1:narg
                if isa(varargin{i},'numeric'), varargin{i} = opMatrix(varargin{i});
                elseif ~isa(varargin{i},'opSpot')
                    error('One of the operators is not a valid input.')
                end
            end
            
            % Determine operator size and complexity (this code is
            % general for any number of operators)
            opA    = varargin{1};
            [m,n]  = size(opA);
            cflag  = opA.cflag;
            linear = opA.linear;
            
            for i=2:narg
                opA    = varargin{i};
                cflag  = cflag  | opA.cflag;
                linear = linear & opA.linear;
                [mi,ni]= size(opA);
                m = m * mi; n = n * ni;
            end
            
            % Construct operator
            op = op@opSpot('Kron', m, n);
            op.cflag    = cflag;
            op.linear   = linear;
            op.children = varargin;
            op.permutation=(1:narg);
            
            %Evaluate the best permutation to use when a multiplication is
            %applied
            if ~ (m == 0 || n == 0)
                op.permutation=op.best_permutation();
            end
        end % Constructor
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Display
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function str = char(op)
            str=['Kron(',char(op.children{1})];
            
            % Get operators
            for i=2:length(op.children)
                str=strcat(str,[', ',char(op.children{i})]);
            end
            str=strcat(str,')');
        end % Char
    end % Methods
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Protected methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    methods ( Access = protected )
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Multiply
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function y = multiply(op,x,mode)
            
            
            %Spot modes (normal[1] or transpose[2])
            
            %The Kronecker Product (KP) is applied to the right-hand matrix
            %taking in account the best order to apply the operators.
            %That necessitates to decompose the KP in successive matrix
            %products with terms of type I(a) kron A kron I(b).
            %A is the operator to apply. I(a) and I(b) are identity 
            %matrices with respective sizes a and b.
            
            opList=op.children;
            m=op.m;
            n=op.n;
            ncol = size(x,2);
            nbr_children = length(opList);
            if ncol>1
                x=x(:);
            end
            
            
            sizes=zeros(nbr_children,2);
            
            %Pre-registering of the sizes
            for i=1:nbr_children
                sizes(i,:)=size(opList{i});
            end
            
            if mode == 1 %Classic mode
                perm = op.permutation;
                
                for i = 1:nbr_children
                    %Index of the operator A to consider.
                    index=perm(i);
                    
                    %Calculation of the sizes of the identity matrices used
                    %in the Kronecker product I(a) kron A kron I(b)
                    
                    %Size of I(a)
                    a = 1;
                    for k = 1:(index-1)
                        if i > find(perm==k)
                            a = a * sizes(k,1);
                        else
                            a = a * sizes(k,2);
                        end
                    end
                    
                    if ncol>1
                        a=a*ncol;
                    end
                    
                    %Size of I(b)
                    b = 1;
                    for k = (index+1):nbr_children
                        if i > find(perm==k)
                            b = b * sizes(k,1);
                        else
                            b = b * sizes(k,2);
                        end
                    end
                    
                    %Index of the operator A to consider.
                    index=perm(i);
                    
                    %Size of the operator A=opList{index} to apply
                    r=sizes(index,1);
                    c=sizes(index,2);
                    
                    %(I(a) kron A kron I(b)) * x;
                    
                    t=reshape(reshape(x,b,a*c).',c,a*b);
                    t=reshape(applyMultiply(opList{index},t,1)',a,r*b)';
                    x=t(:);
                end
                y = reshape(x,m,ncol);
                
            elseif mode == 2 %Transpose mode
                perm = op.permutation(length(opList):-1:1);
                
                for i = 1:nbr_children
                    %Index of the operator A to consider.
                    index=perm(i);
                    
                    %Calculation of the sizes of the identity matrices used
                    %in the Kronecker product I(a) kron A kron I(b)
                    
                    %Size of I(a)
                    a = 1;
                    for k = 1:(index-1)
                        if i > find(perm==k)
                            a = a * size(opList{k},2);
                        else
                            a = a * size(opList{k},1);
                        end
                    end
                    
                    if ncol>1
                        a=a*ncol;
                    end
                    
                    %Size of I(b)
                    b = 1;
                    for k = (index+1):length(opList)
                        if i > find(perm==k)
                            b = b * size(opList{k},2);
                        else
                            b = b * size(opList{k},1);
                        end
                    end
                    
                    %Size of the operator A=opList{index} to apply
                    r=sizes(index,2);
                    c=sizes(index,1);
                    
                    %(I(a) kron A kron I(b)) * x;
                    
                    t=reshape(reshape(x,b,a*c).',c,a*b);
                    t=reshape(applyMultiply(opList{index},t,2)',a,r*b)';
                    x=t(:);
                end
                y=reshape(x,n,ncol);
            end
        end % Multiply
    end %Protected methods
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Private methods
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    methods (Access = private)
        
        %Returns the best permutation associated to this Kronecker Product
        function perm=best_permutation(op)
            list=op.children;
            cost=zeros(1,length(list));
            for i=1:length(list)
                cost(1,i)=(size(list{i},1)-size(list{i},2))/...
                    (size(list{i},1)*size(list{i},2));
            end
            
            perm=op.quicksort(cost,1,length(cost),op.permutation);
        end
        
        %Function doing a quick sort on the vector containing the
        %computational costs associated to the operators of the Kronecker
        %Product. The corresponding permutation 'perm' is returned as an
        %output. It contains the indices of the operators which have to be
        %successively applied to the data vector. These laters are
        %bracketed from left to right.
        
        %n: permutation enabling to follow the transpositions during the
        %recursive application of the quick sort function.
        %n initialy rates [1,2,..,n] where n is the number of operators in
        %the Kronecker Product.
        
        %start and stop: indices of the sort area in the cost vector.
        
        function perm=quicksort(op,cost,start,stop,n)
            
            if start<stop
                left=start;
                right=stop;
                pivot=cost(start);
                
                while 1
                    while cost(right)>pivot,right=right-1;
                    end
                    if cost(right)==pivot && right>start
                        right=right-1;
                    end
                    while cost(left)<pivot,left=left+1;
                    end
                    
                    if(left<right)
                        temp=cost(left);
                        cost(left)=cost(right);
                        cost(right)=temp;
                        
                        temp=n(left);
                        n(left)=n(right);
                        n(right)=temp;
                    else break
                    end
                end
                n=op.quicksort(cost, start, right,n);
                n=op.quicksort(cost, right+1, stop,n);
            end
            perm=n;
        end
    end
end % Classdef


