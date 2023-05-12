package io.sanchopansa.lolwiki.luaanalyzer;

import java.util.Arrays;
import java.util.List;
import java.util.regex.MatchResult;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class LuaAnalyzer {

    public LuaAnalyzer() {

    }

    public void analyzeLuaDependencies(String code) {
        System.out.println(code);
        String requirePattern = "require *?\\((\\\\\"|')(.*?)(\\\\\"|')\\)";
        Pattern pattern = Pattern.compile(requirePattern);
        Matcher matcher = pattern.matcher(code);

        List<String> requiresList = matcher.results().map(a -> a.group(2)).toList();
        requiresList.forEach(System.out::println);
    }
}
