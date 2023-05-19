package io.sanchopansa.lolwiki.luaanalyzer;

import java.util.Set;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

public class LuaAnalyzer {

    public LuaAnalyzer() {

    }

    public Set<String> analyzeLuaDependencies(String code) {
        Set<String> dependencies;

        String requirePattern = "require *?\\((\\\\\"|')(.*?)(\\\\\"|')\\)";
        Pattern pattern = Pattern.compile(requirePattern);
        Matcher matcher = pattern.matcher(code);

        dependencies = matcher.results()
                .map(a -> a.group(2))
                .collect(Collectors.toSet());
        return dependencies;
    }
}
