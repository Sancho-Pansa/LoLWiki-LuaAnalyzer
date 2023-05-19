package io.sanchopansa.lolwiki.luaanalyzer.lualinter;

import java.util.List;
import java.util.regex.MatchResult;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

public class LuaLinter {
    private final String code;

    private List<LuaFunction> functionList;

    public LuaLinter(String code) {
        this.code = code;
    }

    public void processCode() {
        Pattern functionDeclarationPattern = Pattern.compile("(?<!local )\\bfunction (\\w*?)\\.?(\\w+)\\((.*?)\\)");
        Matcher m = functionDeclarationPattern.matcher(this.code);

        functionList = m.results().map((MatchResult a) -> {
            LuaFunction.LuaFunctionBuilder fBuilder = new LuaFunction.LuaFunctionBuilder();
            fBuilder.parentTable(a.group(1))
                    .name(a.group(2));
            if(a.group(3) != null)
                fBuilder.arguments(a.group(3).split(", *"));
            return fBuilder.build();
        }).collect(Collectors.toList());
    }

    public List<LuaFunction> getFunctionList() {
        return functionList;
    }
}
