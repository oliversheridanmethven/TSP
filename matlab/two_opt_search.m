function [ p, d, t ] = two_opt_search( M )
% Author: Ana Osojnik
% Date: December 2016
% Description:
%   Performs a 2-opt search by considenring two-switches of edges. See Tabu
%   search for more comments, disregarding the use of memory lists.

% Input:
%     M: Matrix, distance matrix between cities.
% Output:
%     p: Array, row vector of permutation of the order of cities to visit.
%     d: Float, total distance travelled in a round trip.
%     t: Float, execution time for algorithm.

tic;
n = size(M,1);

% Initial best guess obtained with greedy algorithm
start = randi([1,10]);
aux_tabu_greedy
d_new = sum(sum(M));

% Find all possible combinations of edges that are allowed to be permuted
possible_moves = nchoosek(1:n,2);
possible_moves = possible_moves( (possible_moves(:,1)==1) + ...
    (possible_moves(:,2)==10) ~= 2, : );
possible_moves = possible_moves( diff(possible_moves') > 1, : );

% Set counts to 0
iter = 0;
count = 0;
overall_count = 0;

% Set maximum counts
max_count = size(possible_moves,1);
batch_size = floor(max_count/5);
max_overall_count = 300*max_count;

while overall_count <= max_overall_count
    iter = iter+1;
    fprintf('Iteration %d:\n',iter)
    
    % Permute moves to randomize search  
    permute_moves = randperm( max_count );
    while (d_new >= d) && (count < max_count)
        size_candidates = min(batch_size,max_count-count);
        candidate_moves = possible_moves( permute_moves(count + (1:size_candidates)), : );
        count = count + size_candidates;
 
        d_candidates = d - M(sub2ind([n,n],p(candidate_moves(:,1)),p(candidate_moves(:,1)+1)));
        d_candidates = d_candidates - M(sub2ind([n,n],p(candidate_moves(:,2)),p(candidate_moves(:,2)+1)));
        d_candidates = d_candidates + M(sub2ind([n,n],p(candidate_moves(:,1)),p(candidate_moves(:,2))));
        d_candidates = d_candidates + M(sub2ind([n,n],p(candidate_moves(:,1)+1),p(candidate_moves(:,2)+1)));
        
        [d_new,new_id] = min(d_candidates);
        fprintf('%d\n',d_new)
        
    end
    overall_count = overall_count + count;
    
    if count == max_count
        fprintf('Cannot find a shorter path than %d. All permutations from the last configuration considered (%d).\n',d,count)
        break
    else
        fprintf('***Improvement found***\n')
        
        % Perform swap of edges
        d = d_new; d_new = d + 1;
        a = candidate_moves(new_id,1); b = candidate_moves(new_id,2);
        p((a+1):b) = p(b:(-1):(a+1));
        count = 0;
    end
    
end
fprintf('Number of iterations is %d (%d).\n',iter,overall_count)
p = p(1:(end-1));

t = toc;

end
