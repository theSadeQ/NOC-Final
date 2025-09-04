function printHeader(title)
%PRINTHEADER  Display a formatted header.
%   PRINTHEADER(TITLE) prints the TITLE between separators.  If TITLE
%   is empty, a generic header is used.
    if nargin < 1 || isempty(title)
        title = 'Optimisation App';
    end
    n = length(title) + 6;
    fprintf('\n%s\n', repmat('=',1,n));
    fprintf('== %s ==\n', title);
    fprintf('%s\n', repmat('=',1,n));
end