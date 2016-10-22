class MusicGenerator implements Runnable {

    private Track[] tracks;
    private int[] sounds;
    private float[] vols;
    private int[][] pps;
    private float[] stereoPositions;
    private int startTime;
    private int endTime;
    private float tickDuration;
    private int samplingRate;

    // Constructor
    MusicGenerator(Track[] tracks, int[] sounds, float[] vols, int[][] pps, float[] stereoPositions, int startTime, int endTime, float tickDuration, int samplingRate) {
        this.tracks = tracks;
        this.sounds = sounds;
        this.vols = vols;
        this.pps = pps;
        this.stereoPositions = stereoPositions;
        this.startTime = startTime;
        this.endTime = endTime;
        this.tickDuration = tickDuration;
        this.samplingRate = samplingRate;
    }

    public void run() {
        try {
            ArrayList<TrackGenerator> trackGenerators = new ArrayList<TrackGenerator>();
            ArrayList<Thread> threads = new ArrayList<Thread>();

            for(int i = 0; i < tracks.length && i < sounds.length; ++i) {
                if(sounds[i] == 0) continue; // Skip the track which we are not interested

                TrackGenerator trackGenerator = new TrackGenerator(tracks[i], sounds[i], vols[i], pps[i], stereoPositions[i], startTime, endTime, tickDuration, samplingRate);
                trackGenerators.add(trackGenerator);

                Thread thread = new Thread(trackGenerator);
                threads.add(thread);
                thread.start();
            }

            for(int i = 0; i < trackGenerators.size(); ++i) {
                threads.get(i).join();
                
            }
        } catch(Exception e) {
            println(e);
            return;
        }
    }
}