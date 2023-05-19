package io.sanchopansa.lolwiki.luaanalyzer;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.util.Optional;
import java.util.TreeSet;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class AllModulesFetcher {

    private final String API_PREFIX = "https://leagueoflegends.fandom.com/ru/api.php?action=query&list=allpages&apnamespace=828&aplimit=500&format=json&formatversion=2";

    public AllModulesFetcher() {

    }

    public TreeSet<String> getAllModules() {
        TreeSet<String> modulesSet = new TreeSet<>();
        Optional<BufferedReader> optionalReader = Optional.ofNullable(this.performConnection());
        StringBuilder sBuilder = new StringBuilder();
        try {
            BufferedReader bReader = optionalReader.orElseThrow();
            bReader.lines().forEach(sBuilder::append);
            bReader.close();
        } catch (IOException e) {
            System.err.println("Buffered Reader is null");
            e.printStackTrace();
        }
        if(sBuilder.isEmpty())
            throw new RuntimeException("BufferedReader contains no data");

        Pattern p = Pattern.compile("\"title\":\"(.*?)\"", Pattern.DOTALL);
        Matcher m = p.matcher(sBuilder.toString());

        m.results()
                .map(a -> a.group(1))
                .filter(s -> !(s.contains("/doc") || s.contains("/data")))
                .forEach(modulesSet::add);

        return modulesSet;
    }

    private BufferedReader performConnection() {
        try {
            URL url = new URL(API_PREFIX);
            System.out.println(url);

            HttpURLConnection urlConnection = (HttpURLConnection) url.openConnection();
            urlConnection.setRequestMethod("GET");
            urlConnection.setRequestProperty("Content-Type", "application/json");
            urlConnection.setRequestProperty("User-Agent", "Mozilla/5.0");

            int responseCode = urlConnection.getResponseCode();
            System.out.println("HTTP :: " + responseCode);
            if(responseCode == HttpURLConnection.HTTP_OK) {
                InputStream is = urlConnection.getInputStream();
                return new BufferedReader(new InputStreamReader(is));
            }
        } catch(MalformedURLException e) {
            System.err.println("Incorrect URL detected");
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        }

        return null;
    }
}
