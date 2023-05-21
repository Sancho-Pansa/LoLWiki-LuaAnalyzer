package io.sanchopansa.lolwiki.luaanalyzer.lualinter;

import java.util.List;
import java.util.Set;
import java.util.regex.MatchResult;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;

public class LuaLinter {
    private final String code;

    public LuaLinter(String code) {
        this.code = code;
    }

    public void processCode() {

    }

    public List<LuaFunction> listAllFunctions() {
        Pattern functionDeclarationPattern = Pattern.compile("(?<!local )function *?(\\w*?)\\.?(\\w+)\\((.*?)\\)");
        Matcher m = functionDeclarationPattern.matcher(this.code);

        List<LuaFunction> functionList = m.results().map((MatchResult a) -> {
            LuaFunction.LuaFunctionBuilder fBuilder = new LuaFunction.LuaFunctionBuilder();
            fBuilder.parentTable(a.group(1))
                    .name(a.group(2));
            if(a.group(3) != null)
                fBuilder.arguments(a.group(3).split(", *"));
            return fBuilder.build();
        }).collect(Collectors.toList());

        return functionList;
    }

    public Set<String> listAllDependencies() {
        Set<String> dependencies;

        // require("Module:SkinData")
        // mw.loadData("Module:ChampionData/data"
        String moduleCallPattern = "(?:require|mw\\.loadData) *?\\((?:\\\\\"|')(.*?)?(\\\\\"|')*+\\)";
        Pattern pattern = Pattern.compile(moduleCallPattern);
        Matcher matcher = pattern.matcher(code);

        dependencies = matcher.results()
                .map(a -> a.group(1))
                .collect(Collectors.toSet());
        return dependencies;
    }

    //TODO
    public List<String> listGlobalVariables() {
        Pattern localVarPattern = Pattern.compile("(.*?)");
        return null;
    }
}
