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

    public String getFunctionCode(LuaFunction function) {
        String functionPattern = String.format("function *?(%s)\\.?(%s)\\((%s)\\)",
                function.getParentTable(),
                function.getName(),
                String.join(", *", function.getArguments()));
        Pattern pattern = Pattern.compile(functionPattern);
        Matcher m = pattern.matcher(code);
        if(m.find()) {
            String subCode = code.substring(m.start());
            Pattern endPattern = Pattern.compile("\\\\nend");
            Matcher endMatcher = endPattern.matcher(subCode);
            endMatcher.find();
            return subCode.substring(0, endMatcher.end());
        }

        return "";
    }

    //TODO
    public List<String> listGlobalVariables() {
        Pattern localVarPattern = Pattern.compile("(.*?)");
        return null;
    }
}
