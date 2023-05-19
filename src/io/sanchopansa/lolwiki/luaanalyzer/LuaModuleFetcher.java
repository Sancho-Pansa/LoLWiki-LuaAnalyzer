package io.sanchopansa.lolwiki.luaanalyzer;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.NoSuchElementException;
import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

public class LuaModuleFetcher {
    private final String API_PREFIX = "https://leagueoflegends.fandom.com/ru/api.php?action=parse&format=json&prop=wikitext&formatversion=2";
    private final String pageName;

    public LuaModuleFetcher(String pageName) {
        this.pageName = pageName;
    }

    public String getLuaCode() {
        Optional<BufferedReader> optionalReader = Optional.ofNullable(this.performConnection());
        StringBuilder sBuilder = new StringBuilder();
        try {
            BufferedReader bReader = optionalReader.orElseThrow();
            bReader.lines().forEach(sBuilder::append);
            bReader.close();
        } catch (IOException e) {
            e.printStackTrace();
        } catch (NoSuchElementException e) {
            System.err.println("BufferedReader is null");
            e.printStackTrace();
        }
        Pattern p = Pattern.compile("\"wikitext\":\"(.*)\"", Pattern.DOTALL);
        Matcher m = p.matcher(sBuilder.toString());
        return m.find() ? m.group() : "";
    }

    private BufferedReader performConnection() {
        try {
            String encodedPageName = URLEncoder.encode(pageName, StandardCharsets.UTF_8);
            URL url = new URL(API_PREFIX + "&page=" + encodedPageName);
            System.out.println(url);

            HttpURLConnection urlConnection = (HttpURLConnection) url.openConnection();
            urlConnection.setRequestMethod("GET");
            urlConnection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
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
