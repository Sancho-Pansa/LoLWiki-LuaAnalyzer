package io.sanchopansa.lolwiki.luaanalyzer;

import java.io.DataOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.stream.Collectors;

public class DependencyListFormatter {
    private final TreeMap<String, Set<String>> dependencyMap;

    public DependencyListFormatter(TreeMap<String, Set<String>> dependencyMap) {
        this.dependencyMap = dependencyMap;
    }

    public void getFormattedOutput(OutputStream writer) throws IOException {
        OutputStream oStream = new DataOutputStream(System.out);
        for(String x: dependencyMap.navigableKeySet()) {
            Set<String> dependencyList = dependencyMap.get(x);
            writer.write((x + "\n").getBytes(StandardCharsets.UTF_8));
            for(String module: dependencyList) {
                writer.write(("\t" + module + "\n").getBytes(StandardCharsets.UTF_8));
            }
            writer.write(("\n").getBytes(StandardCharsets.UTF_8));
        }
    }

    public int[][] convertToGraph() {
        // Calculate number of all modules in Wiki
        var allDependencies = dependencyMap.values();
        List<String> distinctModules = new ArrayList<>();
        for(Set<String> x: allDependencies) {
            distinctModules.addAll(x);
        }
        distinctModules = distinctModules.stream()
                .distinct()
                .sorted()
                .collect(Collectors.toList());
        int[][] dependencyGraph = new int[distinctModules.size()][distinctModules.size()];
        for(int i = 0; i < dependencyGraph.length; i++) {
            String dependentModule = distinctModules.get(i);
            for(int j = 0; j < dependencyGraph[i].length; j++) {
                String usedModule = distinctModules.get(j);
                if(dependencyMap.containsKey(dependentModule))
                    dependencyGraph[i][j] = dependencyMap.get(dependentModule).contains(usedModule) ? 1 : 0;
                else
                    dependencyGraph[i][j] = 0;
            }
        }
        return dependencyGraph;
    }
}
