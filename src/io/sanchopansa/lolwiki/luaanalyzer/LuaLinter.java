package io.sanchopansa.lolwiki.luaanalyzer;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class LuaLinter {
    private String code;
    public LuaLinter(String code) {
        this.code = code;
    }

    public List<String> getCodeStructure() {
        List<String> lineBrokeCode = Arrays.asList(code.split("\r\n"));
        List<String> localDeclarations = new ArrayList<>();
        for(String x: lineBrokeCode) {
            Pattern localDeclarationsPattern = Pattern.compile("\\blocal\\b ");
            Matcher m = localDeclarationsPattern.matcher(x);
            if(m.find())
                localDeclarations.add(m.group());
        }
        return localDeclarations;
    }
}
