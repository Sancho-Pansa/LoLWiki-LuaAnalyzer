package io.sanchopansa.lolwiki.luaanalyzer;

import java.util.TreeSet;

public class MainClass {
    public static void main(String[] args) {
        AllModulesFetcher modulesFetcher = new AllModulesFetcher();
        TreeSet<String> modules = modulesFetcher.getAllModules();

        for(String x: modules) {
            System.out.println(x);
            LuaModuleFetcher singleModuleFetcher = new LuaModuleFetcher(x);
            String sourceCode = singleModuleFetcher.getLuaCode();
            LuaAnalyzer analyzer = new LuaAnalyzer();
            var set = analyzer.analyzeLuaDependencies(sourceCode);
            set.forEach(System.out::println);
        }
    }
}
