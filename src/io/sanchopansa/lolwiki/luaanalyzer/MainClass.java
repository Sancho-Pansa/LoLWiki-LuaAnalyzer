package io.sanchopansa.lolwiki.luaanalyzer;

import java.io.IOException;
import java.util.Arrays;
import java.util.Set;
import java.util.TreeMap;
import java.util.TreeSet;

public class MainClass {
    public static void main(String[] args) {
        AllModulesFetcher modulesFetcher = new AllModulesFetcher();
        TreeSet<String> modules = modulesFetcher.getAllModules();

        TreeMap<String, Set<String>> luaDependencyMap = new TreeMap<>();

        for(String x: modules) {
            ModuleFetcher singleModuleFetcher = new ModuleFetcher(x);
            String sourceCode = singleModuleFetcher.getLuaCode();
            ModuleAnalyzer analyzer = new ModuleAnalyzer();
            var set = analyzer.analyzeLuaDependencies(sourceCode);
            luaDependencyMap.put(x, set);
        }

        DependencyListFormatter formatter = new DependencyListFormatter(luaDependencyMap);
        try {
            formatter.getFormattedOutput(System.out);
        } catch (IOException e) {
            e.printStackTrace();
        }

        StringBuilder sBuilder = new StringBuilder();
        Arrays.stream(formatter.convertToGraph())
                .forEach(a -> {
                    sBuilder.append("[");
                    Arrays.stream(a)
                            .forEach(b -> {
                                sBuilder.append(b);
                                sBuilder.append(", ");
                            });
                    sBuilder.append("]\n");
                });
        System.out.println(sBuilder);
    }
}
