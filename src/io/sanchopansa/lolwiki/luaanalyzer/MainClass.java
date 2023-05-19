package io.sanchopansa.lolwiki.luaanalyzer;

import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;

public class MainClass {
    public static void main(String[] args) {
        AllModulesFetcher modulesFetcher = new AllModulesFetcher();
        TreeSet<String> modules = modulesFetcher.getAllModules();

        TreeMap<String, Set<String>> luaDependencyMap = new TreeMap<>();

        for(String x: modules) {
            LuaModuleFetcher singleModuleFetcher = new LuaModuleFetcher(x);
            String sourceCode = singleModuleFetcher.getLuaCode();
            LuaAnalyzer analyzer = new LuaAnalyzer();
            var set = analyzer.analyzeLuaDependencies(sourceCode);
            luaDependencyMap.put(x, set);
        }
    }
}
