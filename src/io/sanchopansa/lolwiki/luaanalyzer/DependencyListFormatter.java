package io.sanchopansa.lolwiki.luaanalyzer;

import java.io.DataOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.charset.StandardCharsets;
import java.util.Set;
import java.util.TreeMap;

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

    public String[] convertToGraph() {
        return null;
    }
}
