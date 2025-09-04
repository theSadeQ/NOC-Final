function spec = readProblemSpec(path)
%READPROBLEMSPEC Parse a simple YAML-like specification into a struct.
%   SPEC = READPROBLEMSPEC(PATH) reads a problem specification file in
%   YAML format (limited subset) and returns a struct with fields
%   corresponding to top-level keys.  Nested keys under `data` are
%   returned in SPEC.data, and numeric strings are converted to doubles.

txt = fileread(path);
lines = strsplit(txt, {'\r','\n'});
spec = struct();
current = '';
for i = 1:numel(lines)
    line = strtrim(lines{i});
    if isempty(line) || startsWith(line,'#')
        continue;
    end
    % If line ends with ':' and no other ':' present, treat as section
    if endsWith(line,':') && count(line,':') == 1
        current = strtrim(strrep(line,':',''));
        spec.(current) = struct();
        continue;
    end
    % parse key: value
    parts = strsplit(line, ':', 2);
    if numel(parts) ~= 2
        continue;
    end
    key = strtrim(parts{1});
    val = strtrim(parts{2});
    % remove surrounding quotes
    if startsWith(val,'"') && endsWith(val,'"')
        val = val(2:end-1);
    end
    if isempty(current)
        spec.(key) = convertValue(val);
    else
        spec.(current).(key) = convertValue(val);
    end
end

    function out = convertValue(v)
        % Try to convert numeric or array
        if strcmpi(v,'[]')
            out = [];
        elseif strcmp(v,'NOT_IMPLEMENTED')
            out = 'NOT_IMPLEMENTED';
        elseif ~isempty(regexp(v,'^[\[\]\d;\s\.-]+$','once'))
            try
                out = eval(v);
            catch
                out = v;
            end
        elseif ~isnan(str2double(v))
            out = str2double(v);
        else
            out = v;
        end
    end
end