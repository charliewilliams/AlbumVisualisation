import java.util.Arrays;
import java.lang.Object;
// Convert from npm midi output json to a more useful in-memory format

class Song {

  String title;
  int lengthMillis;
  HashMap<Float, Note> notes;
  Float[] timestamps;
  int noteCount;

  Song(String title, String filename, int lengthSeconds) {

    this.title = title;
    notes = loadJSONFile(filename);
    noteCount = notes.size();
    lengthMillis = lengthSeconds * 1000;

    // put the timestamps in order
    int count = notes.size();
    timestamps = new Float[count];

    int i = 0;
    for (Float noteTime : notes.keySet()) {
      timestamps[i] = noteTime;
      i++;
    }

    Arrays.sort(timestamps);
  }

  private HashMap<Float, Note> loadJSONFile(String name) {

    HashMap<Float, Note> notes = new HashMap<Float, Note>();

    JSONObject json = loadJSONObject(name);
    JSONArray tracks = json.getJSONArray("tracks");

    for (int i = 0; i < tracks.size(); i++) {

      JSONObject track = tracks.getJSONObject(i);

      if (track.get("id") == null) {
        continue;
      }
      Integer channel = track.getInt("id");
      JSONArray notesJSON = track.getJSONArray("notes");

      //println(notesJSON.size(), "notes in track", i, "(channel", channel, ")");

      // Pull each note's JSON, create a Note object, and add it to the "notes" hashmap
      for (int j = 0; j < notesJSON.size(); j++) {

        JSONObject noteJSON = notesJSON.getJSONObject(j);

        Integer noteNumber = noteJSON.getInt("midi");
        Float velocity = noteJSON.getFloat("velocity");
        Float duration = noteJSON.getFloat("duration");
        Float timestamp = noteJSON.getFloat("time");

        Note note = new Note(noteNumber, velocity, duration, channel);
        notes.put(timestamp, note);
      }
    }

    return notes;
  }
}
