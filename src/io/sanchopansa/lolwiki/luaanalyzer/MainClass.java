package io.sanchopansa.lolwiki.luaanalyzer;

public class MainClass {
    public static void main(String[] args) {
        String code = new LuaFetcher("Модуль:SkinData").getLuaCode();
        LuaAnalyzer analyzer = new LuaAnalyzer();
        var set = analyzer.analyzeLuaDependencies(code);
        set.forEach(System.out::println);
    }
}
