import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:media_kit/src/models/playable.dart';
import 'package:path/path.dart' show join;
import 'package:test/test.dart';
import 'package:collection/collection.dart';

import 'package:media_kit/src/models/track.dart';
import 'package:media_kit/src/models/audio_device.dart';
import 'package:media_kit/src/models/audio_params.dart';
import 'package:media_kit/src/models/video_params.dart';
import 'package:media_kit/src/models/playlist_mode.dart';
import 'package:media_kit/src/models/subtitle.dart';

import 'package:media_kit/src/media_kit.dart';
import 'package:media_kit/src/player/player.dart';
import 'package:media_kit/src/player/platform_player.dart';
import 'package:media_kit/src/player/native/player/player.dart';

import '../../common/sources.dart';

void main() {
  setUp(() async {
    MediaKit.ensureInitialized();

    await sources.prepare();

    // For preventing video driver & audio driver initialization errors in unit-tests.
    NativePlayer.test = true;
  });
  test('player-wait-for-player-initialization', () async {
    final player = await Player.create();
    final future = player.waitForPlayerInitialization;
    expect(future, isNotNull);
    expect(future, completes);

    await Future.delayed(const Duration(seconds: 10));

    await player.dispose();
  });
  test('player-configuration-ready-callback', () async {
    final expectReady = expectAsync0(() {});

    final player = await Player.create(
      configuration: PlayerConfiguration(ready: expectReady),
    );

    addTearDown(player.dispose);
  });
  test('player-open-playable-media', () async {
    final player = await Player.create();

    expect(
      player.stream.playlist,
      emitsInOrder([
        Playlist([Media(sources.platform[0])], index: 0),
        // Player.dispose
        emitsDone,
      ]),
    );
    expect(
      player.stream.playing,
      emitsInOrder([
        // Player.open
        false,
        true,
        // EOF
        false,
        // Player.dispose
        emitsDone,
      ]),
    );
    expect(
      player.stream.completed,
      emitsInOrder([
        // Player.open
        false,
        // EOF
        true,
        // Player.dispose
        emitsDone,
      ]),
    );

    await player.open(Media(sources.platform[0]));

    await Future.delayed(const Duration(seconds: 30));

    await player.dispose();
  }, timeout: Timeout(const Duration(minutes: 1)));
  test('player-open-playable-playlist', () async {
    final player = await Player.create();

    final playable = Playlist([
      for (int i = 0; i < sources.platform.length; i++)
        Media(sources.platform[i]),
    ]);

    expect(
      player.stream.playlist,
      emitsInOrder([
        // Player.open
        for (int i = 0; i < sources.platform.length; i++)
          playable.copyWith(index: i),
        // Player.dispose
        emitsDone,
      ]),
    );

    expect(
      player.stream.playing,
      emitsInOrder([
        // Player.open
        false,
        true,
        // -> 1
        false,
        true,
        // -> 2
        false,
        true,
        // -> 3
        false,
        true,
        // EOF
        false,
        // Player.dispose
        emitsDone,
      ]),
    );
    expect(
      player.stream.completed,
      emitsInOrder([
        // Player.open
        false,
        // -> 1
        true,
        false,
        // -> 2
        true,
        false,
        // -> 3
        true,
        false,
        // EOF
        true,
        // Player.dispose
        emitsDone,
      ]),
    );

    await player.open(playable);

    await Future.delayed(const Duration(minutes: 1, seconds: 30));

    await player.dispose();
  }, timeout: Timeout(const Duration(minutes: 2)));
  test(
    'player-open-playable-media-play-false',
    () async {
      final player = await Player.create();

      expect(
        player.stream.playlist,
        emitsInOrder([
          // Player.open
          Playlist([Media(sources.platform[0])], index: 0),
          // Player.dispose
          emitsDone,
        ]),
      );
      expect(
        player.stream.playing,
        emitsInOrder([
          // Player.open
          false,
          // Player.dispose
          emitsDone,
        ]),
      );

      await player.open(Media(sources.platform[0]), play: false);

      await Future.delayed(const Duration(seconds: 30));

      await player.dispose();
    },
    timeout: Timeout(const Duration(minutes: 1)),
  );
  test(
    'player-open-playable-playlist-play-false',
    () async {
      final player = await Player.create();

      final playable = Playlist([
        for (int i = 0; i < sources.platform.length; i++)
          Media(sources.platform[i]),
      ]);

      expect(
        player.stream.playlist,
        emitsInOrder([
          playable,
          // Player.dispose
          emitsDone,
        ]),
      );
      expect(
        player.stream.playing,
        emitsInOrder([
          // Player.open
          false,
          // Player.dispose
          emitsDone,
        ]),
      );

      await player.open(playable, play: false);

      await Future.delayed(const Duration(seconds: 30));

      await player.dispose();
    },
    timeout: Timeout(const Duration(minutes: 1)),
  );
  test(
    'player-open-playable-media-play-false-play',
    () async {
      final player = await Player.create();

      expect(
        player.stream.playlist,
        emitsInOrder([
          Playlist([Media(sources.platform[0])], index: 0),
          // Player.dispose
          emitsDone,
        ]),
      );
      expect(
        player.stream.playing,
        emitsInOrder([
          // Player.open
          false,
          // Player.play
          true,
          // EOF
          false,
          // Player.dispose
          emitsDone,
        ]),
      );
      expect(
        player.stream.completed,
        emitsInOrder([
          // Player.open
          // Player.play
          false,
          // EOF
          true,
          // Player.dispose
          emitsDone,
        ]),
      );

      await player.open(Media(sources.platform[0]), play: false);
      await player.play();

      await Future.delayed(const Duration(seconds: 30));

      await player.dispose();
    },
    timeout: Timeout(const Duration(minutes: 1)),
  );

  test(
    'player-open-playable-playlist-play-false-play',
    () async {
      final player = await Player.create();

      final playable = Playlist([
        for (int i = 0; i < sources.platform.length; i++)
          Media(sources.platform[i]),
      ]);

      expect(
        player.stream.playlist,
        emitsInOrder([
          for (int i = 0; i < sources.platform.length; i++)
            playable.copyWith(index: i),
          // Player.dispose
          emitsDone,
        ]),
      );

      expect(
        player.stream.playing,
        emitsInOrder([
          // Player.open
          false,
          true,
          // -> 1
          false,
          true,
          // -> 2
          false,
          true,
          // -> 3
          false,
          true,
          // EOF
          false,
          // Player.dispose
          emitsDone,
        ]),
      );
      expect(
        player.stream.completed,
        emitsInOrder([
          // Player.open
          false,
          // -> 1
          true,
          false,
          // -> 2
          true,
          false,
          // -> 3
          true,
          false,
          // EOF
          true,
          // Player.dispose
          emitsDone,
        ]),
      );

      await player.open(playable, play: false);
      await player.play();

      await Future.delayed(const Duration(minutes: 1, seconds: 30));

      await player.dispose();
    },
    timeout: Timeout(const Duration(minutes: 2)),
  );
  test(
    'player-open-playable-media-extras',
    () async {
      final player = await Player.create();

      final expectExtras = expectAsync1((value) {
        print(value);
        expect(value, isA<Map<String, dynamic>>());
        final extras = value as Map<String, dynamic>;
        expect(
          MapEquality().equals(extras, {'foo': 'bar', 'baz': 'qux'}),
          true,
        );
      });

      player.stream.playlist.listen((e) {
        if (e.index >= 0) {
          expectExtras(e.medias[0].extras);
        }
      });

      await player.open(
        Media(sources.platform[0], extras: {'foo': 'bar', 'baz': 'qux'}),
      );

      await Future.delayed(const Duration(seconds: 30));

      await player.dispose();
    },
    timeout: Timeout(const Duration(minutes: 1)),
  );
  test(
    'player-open-playable-playlist-extras',
    () async {
      final player = await Player.create();

      final expectExtras = expectAsync2((value, i) {
        print(value);
        expect(value, isA<Map<String, dynamic>>());
        final extras = value as Map<String, dynamic>;
        expect(MapEquality().equals(extras, {'i': i.toString()}), true);
      }, count: sources.platform.length);

      player.stream.playlist.listen((e) {
        if (e.index >= 0) {
          expectExtras(e.medias[e.index].extras, e.index);
        }
      });

      await player.open(
        Playlist([
          for (int i = 0; i < sources.platform.length; i++)
            Media(sources.platform[i], extras: {'i': i.toString()}),
        ]),
      );

      await Future.delayed(const Duration(minutes: 1));

      await player.dispose();
    },
    timeout: Timeout(const Duration(minutes: 1, seconds: 30)),
  );
  test(
    'player-open-playable-media-start-end',
    () async {
      final player = await Player.create();

      final expectStart = expectAsync1((value) {
        expect(value, isA<Duration>());
        final start = value as Duration;
        expect(start, const Duration(seconds: 2));
      });
      final expectEnd = expectAsync1((value) {
        expect(value, isA<Duration>());
        final end = value as Duration;
        expect(end, const Duration(seconds: 5));
      });

      int i = 0;
      final expectPosition = expectAsync1(
        (value) {
          print(value);

          expect(value, isA<Duration>());
          final position = value as Duration;

          if (i == 0) {
            expect(position, Duration.zero);
          } else if (i == 1) {
            expect(position, const Duration(seconds: 2));
          } else {
            expect(position, greaterThan(const Duration(seconds: 2)));
            expect(position, lessThanOrEqualTo(const Duration(seconds: 5)));
          }

          i++;
        },
        count: 1,
        max: -1,
      );

      player.stream.playlist.listen((e) {
        if (e.index >= 0) {
          expectStart(e.medias[0].start);
          expectEnd(e.medias[0].end);
        }
      });

      player.stream.position.listen((e) {
        expectPosition(e);
      });

      await player.open(
        Media(
          sources.platform[0],
          start: const Duration(seconds: 2),
          end: const Duration(seconds: 5),
        ),
      );

      await Future.delayed(const Duration(seconds: 30));

      await player.dispose();
    },
    timeout: Timeout(const Duration(minutes: 1)),
  );
  test(
    'player-open-playable-playlist-start-end',
    () async {
      final player = await Player.create();

      final expectStart = expectAsync2((value, i) {
        print('----- start: $value');
        expect(value, isA<Duration>());
        final start = value as Duration;
        expect(start, Duration(seconds: ((i as int) + 1)));
      }, count: sources.platform.length);
      final expectEnd = expectAsync2((value, i) {
        print('----- end: $value');
        expect(value, isA<Duration>());
        final end = value as Duration;
        expect(end, Duration(seconds: ((i as int) + 1) * 2));
      }, count: sources.platform.length);

      StreamSubscription<Duration>? subscription;

      player.stream.playlist.listen((e) {
        if (e.index >= 0) {
          expectStart(e.medias[e.index].start, e.index);
          expectEnd(e.medias[e.index].end, e.index);

          // Check for position updates of this [Media].
          int i = 0;
          final expectPosition = expectAsync1(
            (value) {
              print(value);

              expect(value, isA<Duration>());
              final position = value as Duration;

              if (i == 0) {
                expect(position, e.medias[e.index].start);
              } else {
                expect(position, greaterThan(e.medias[e.index].start!));
                expect(position, lessThanOrEqualTo(e.medias[e.index].end!));
              }

              i++;
            },
            count: 1,
            max: -1,
          );

          // NOTE: Make sure to unsubscribe at EOF.
          subscription = player.stream.position.listen((e) {
            expectPosition(e);
          });
        }
      });

      player.stream.completed.listen((e) {
        if (e) {
          subscription?.cancel();
        }
      });

      await player.open(
        Playlist([
          for (int i = 0; i < sources.platform.length; i++)
            Media(
              sources.platform[i],
              start: Duration(seconds: (i + 1)),
              end: Duration(seconds: (i + 1) * 2),
            ),
        ]),
      );

      await Future.delayed(const Duration(minutes: 1));

      await player.dispose();
    },
    timeout: Timeout(const Duration(minutes: 1, seconds: 30)),
  );
  test('player-play-after-completed', () async {
    // Only applicable for PlaylistMode.none.

    final completer = Completer();

    final player = await Player.create();

    expect(
      player.stream.playing,
      emitsInOrder([
        // Player.open
        false,
        true,
        // EOF
        false,
        // Player.play
        true,
      ]),
    );
    expect(
      player.stream.completed,
      emitsInOrder([
        // Player.open
        false,
        // EOF
        true,
        // Player.play
        false,
      ]),
    );

    player.stream.completed.listen((event) {
      if (!completer.isCompleted) {
        if (event) {
          completer.complete();
        }
      }
    });

    await player.open(Media(sources.platform[0]));

    // Wait for EOF.
    await completer.future;

    final expectPosition = expectAsync1(
      (value) {
        print(value);
        expect(value, isA<Duration>());
      },
      count: 1,
      max: -1,
    );

    player.stream.position.listen((event) async {
      if (event > Duration.zero) {
        print(event);
        expectPosition(event);
      }
    });

    await Future.delayed(const Duration(seconds: 5));

    // Begin test.

    await player.play();

    // End test.

    await Future.delayed(const Duration(seconds: 5));

    await player.dispose();
  }, timeout: Timeout(const Duration(minutes: 1)));
  test('player-seek-after-completed', () async {
    final completer = Completer();

    final player = await Player.create();

    expect(
      player.stream.playing,
      emitsInOrder([
        // Player.open
        false,
        true,
        // EOF
        false,
        // Player.seek
        // ---------
      ]),
    );
    expect(
      player.stream.completed,
      emitsInOrder([
        // Player.open
        false,
        // EOF
        true,
        // Player.seek
        false,
      ]),
    );

    player.stream.completed.listen((event) {
      if (!completer.isCompleted) {
        if (event) {
          completer.complete();
        }
      }
    });

    await player.open(Media(sources.platform[0]));

    // Wait for EOF.
    await completer.future;

    final expectPosition = expectAsync1(
      (value) {
        print(value);
        expect(value, isA<Duration>());
        final position = value as Duration;
        expect(position, Duration.zero);
      },
      count: 1,
      max: -1,
    );

    player.stream.position.listen((event) async {
      print(event);
      expectPosition(event);
    });

    // NOTE: VOLUNTARY DELAY.
    await Future.delayed(const Duration(seconds: 5));

    // Begin test.

    await player.seek(Duration.zero);

    // End test.

    await Future.delayed(const Duration(seconds: 5));

    await player.dispose();
  }, timeout: Timeout(const Duration(minutes: 1)));
  test('player-open-while-playing', () async {
    final player = await Player.create();

    expect(
      player.stream.playlist,
      emitsInOrder([
        Playlist([Media(sources.platform[0])], index: 0),
        Playlist([Media(sources.platform[1])], index: 0),
      ]),
    );
    expect(player.stream.playing, emitsInOrder([false, true, false, true]));
    // NOTE: Not emitted when the playable is changed mid-playback. Only upon end of file.
    expect(player.stream.completed, emitsInOrder([false, true]));

    await player.open(Media(sources.platform[0]));

    await Future.delayed(const Duration(seconds: 5));

    await player.open(Media(sources.platform[1]));

    addTearDown(player.dispose);
  }, timeout: Timeout(const Duration(minutes: 1)));
  test(
    'player-open-playable-playlist-non-zero-index',
    () async {
      final player = await Player.create();

      final playable = Playlist([
        for (int i = 0; i < sources.platform.length; i++)
          Media(sources.platform[i]),
      ], index: sources.platform.length - 1);

      expect(player.stream.playlist, emits(playable));

      await player.open(playable);

      addTearDown(player.dispose);
    },
    skip: kSkipFlakyTests,
    timeout: Timeout(const Duration(minutes: 1)),
  );
  test('player-set-audio-device', () async {
    final player = await Player.create();

    expect(player.setAudioDevice(AudioDevice.auto()), throwsUnsupportedError);

    addTearDown(player.dispose);
  }, skip: true);
  test('player-set-pitch-disabled', () async {
    final player = await Player.create();

    expect(player.setPitch(1.0), throwsArgumentError);

    addTearDown(player.dispose);
  }, skip: false);
  test('player-set-pitch-enabled', () async {
    final player = await Player.create(
      configuration: PlayerConfiguration(pitch: true),
    );

    expect(player.setPitch(1.0), throwsUnsupportedError);

    addTearDown(player.dispose);
  }, skip: true);
  test('player-jump', () async {
    final player = await Player.create();

    final playable = Playlist([
      for (int i = 0; i < sources.platform.length; i++)
        Media(sources.platform[i]),
    ]);
    expect(
      player.stream.playlist,
      emitsInOrder([
        // Player.open
        TypeMatcher<Playlist>().having(
          (playlist) => playlist.index,
          'index',
          equals(0),
        ),
        // Player.jump
        TypeMatcher<Playlist>().having(
          (playlist) => playlist.index,
          'index',
          equals(2),
        ),
      ]),
    );

    await player.open(playable);

    // NOTE: VOLUNTARY DELAY.
    await Future.delayed(const Duration(seconds: 5));

    await player.jump(2);

    await Future.delayed(const Duration(seconds: 30));

    await player.dispose();
  }, timeout: Timeout(const Duration(minutes: 1)));
  test('player-move', () async {
    final player = await Player.create();

    final playable = Playlist([
      for (int i = 0; i < sources.platform.length; i++)
        Media(sources.platform[i]),
    ]);

    expect(
      player.stream.playlist,
      emitsInOrder([
        // Player.open
        playable,
        // Player.move
        Playlist(move(playable.medias, 1, 3)),
      ]),
    );

    await player.open(playable);

    // NOTE: VOLUNTARY DELAY.
    await Future.delayed(const Duration(seconds: 5));

    await player.move(1, 3);

    await Future.delayed(const Duration(seconds: 30));

    await player.dispose();
  }, timeout: Timeout(const Duration(minutes: 1)));
  test(
    'player-index-transitions-playlist-mode-none',
    () async {
      final player = await Player.create();

      final playable = Playlist([
        for (int i = 0; i < sources.platform.length; i++)
          Media(sources.platform[i]),
      ]);

      expect(
        player.stream.playlist,
        emitsInOrder([
          // index: 0 -> sources.platform.length - 1
          for (int i = 0; i < sources.platform.length; i++)
            playable.copyWith(index: i),
          emitsDone,
        ]),
      );

      await player.setPlaylistMode(PlaylistMode.none);
      await player.open(playable);

      await Future.delayed(const Duration(minutes: 1));

      await player.dispose();
    },
    timeout: Timeout(const Duration(minutes: 1, seconds: 30)),
  );
  test(
    'player-index-transitions-playlist-mode-single',
    () async {
      final player = await Player.create();

      final playable = Playlist([
        for (int i = 0; i < sources.platform.length; i++)
          Media(sources.platform[i]),
      ]);

      expect(
        player.stream.playlist,
        emitsInOrder([
          // index: 0 (does not change)
          playable.copyWith(index: 0),
          emitsDone,
        ]),
      );

      await player.setPlaylistMode(PlaylistMode.single);
      await player.open(playable);

      await Future.delayed(const Duration(minutes: 1));

      await player.dispose();
    },
    timeout: Timeout(const Duration(minutes: 1, seconds: 30)),
  );
  test(
    'player-index-transitions-playlist-mode-loop',
    () async {
      final player = await Player.create();

      final playable = Playlist([
        for (int i = 0; i < sources.platform.length; i++)
          Media(sources.platform[i]),
      ]);

      expect(
        player.stream.playlist,
        emitsInOrder([
          // index: 0 -> sources.platform.length - 1
          for (int i = 0; i < sources.platform.length; i++)
            playable.copyWith(index: i),

          // must loop back to index: 0

          // index: 0 -> sources.platform.length - 1
          for (int i = 0; i < sources.platform.length; i++)
            playable.copyWith(index: i),
        ]),
      );

      await player.setPlaylistMode(PlaylistMode.loop);
      await player.open(playable);

      await Future.delayed(const Duration(minutes: 2, seconds: 30));

      await player.dispose();
    },
    timeout: Timeout(const Duration(minutes: 5)),
  );
  test('player-next-playlist-mode-none', () async {
    final player = await Player.create();

    final playable = Playlist([
      for (int i = 0; i < sources.platform.length; i++)
        Media(sources.platform[i]),
    ]);

    expect(
      player.stream.playlist,
      emitsInOrder([
        // index: 0 -> sources.platform.length - 1
        for (int i = 0; i < sources.platform.length; i++)
          playable.copyWith(index: i),
        emitsDone,
      ]),
    );

    await player.setPlaylistMode(PlaylistMode.none);
    await player.open(playable);

    final timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      try {
        await player.next();
      } catch (_) {}
    });

    await Future.delayed(const Duration(seconds: 15));

    timer.cancel();
    await player.dispose();
  }, timeout: Timeout(const Duration(minutes: 1)));
  test(
    'player-next-playlist-mode-single',
    () async {
      final player = await Player.create();

      final playable = Playlist([
        for (int i = 0; i < sources.platform.length; i++)
          Media(sources.platform[i]),
      ]);

      expect(
        player.stream.playlist,
        emitsInOrder([
          // index: 0 -> sources.platform.length - 1
          for (int i = 0; i < sources.platform.length; i++)
            playable.copyWith(index: i),
          emitsDone,
        ]),
      );

      await player.setPlaylistMode(PlaylistMode.single);
      await player.open(playable);

      final timer = Timer.periodic(const Duration(seconds: 1), (_) async {
        try {
          await player.next();
        } catch (_) {}
      });

      await Future.delayed(const Duration(seconds: 15));

      timer.cancel();
      await player.dispose();
    },
    timeout: Timeout(const Duration(minutes: 1)),
  );
  test('player-next-playlist-mode-loop', () async {
    final player = await Player.create();

    final playable = Playlist([
      for (int i = 0; i < sources.platform.length; i++)
        Media(sources.platform[i]),
    ]);

    expect(
      player.stream.playlist,
      emitsInOrder([
        // index: 0 -> sources.platform.length - 1
        for (int i = 0; i < sources.platform.length; i++)
          playable.copyWith(index: i),

        // must loop back to index: 0

        // index: 0 -> sources.platform.length - 1
        for (int i = 0; i < sources.platform.length; i++)
          playable.copyWith(index: i),
      ]),
    );

    await player.setPlaylistMode(PlaylistMode.loop);
    await player.open(playable);

    final timer = Timer.periodic(const Duration(seconds: 1), (_) async {
      try {
        await player.next();
      } catch (_) {}
    });

    await Future.delayed(const Duration(seconds: 15));

    timer.cancel();
    await player.dispose();
  }, timeout: Timeout(const Duration(minutes: 1)));
  test(
    'player-previous-playlist-mode-none',
    () async {
      final player = await Player.create();

      final playable = Playlist([
        for (int i = 0; i < sources.platform.length; i++)
          Media(sources.platform[i]),
      ]);

      expect(
        player.stream.playlist,
        emitsInOrder([
          playable,
          // index: sources.platform.length - 1 -> 0
          for (int i = sources.platform.length - 1; i >= 0; i--)
            playable.copyWith(index: i),
          // Cannot test (since index keeps transitioning):
          // emitsDone,
        ]),
      );

      await player.setPlaylistMode(PlaylistMode.none);
      await player.open(playable);

      // NOTE: VOLUNTARY DELAY.
      await Future.delayed(const Duration(seconds: 5));

      await player.jump(sources.platform.length - 1);

      final timer = Timer.periodic(const Duration(seconds: 1), (_) async {
        try {
          await player.previous();
        } catch (_) {}
      });

      await Future.delayed(const Duration(seconds: 45));

      timer.cancel();
      await player.dispose();
    },
    timeout: Timeout(const Duration(minutes: 1)),
  );
  test(
    'player-previous-playlist-mode-single',
    () async {
      final player = await Player.create();

      final playable = Playlist([
        for (int i = 0; i < sources.platform.length; i++)
          Media(sources.platform[i]),
      ]);

      expect(
        player.stream.playlist,
        emitsInOrder([
          playable,
          // index: sources.platform.length - 1 -> 0
          for (int i = sources.platform.length - 1; i >= 0; i--)
            playable.copyWith(index: i),
          // Cannot test (since index keeps transitioning):
          // emitsDone,
        ]),
      );

      await player.setPlaylistMode(PlaylistMode.single);
      await player.open(playable);

      // NOTE: VOLUNTARY DELAY.
      await Future.delayed(const Duration(seconds: 5));

      await player.jump(sources.platform.length - 1);

      final timer = Timer.periodic(const Duration(seconds: 1), (_) async {
        try {
          await player.previous();
        } catch (_) {}
      });

      await Future.delayed(const Duration(seconds: 45));

      timer.cancel();
      await player.dispose();
    },
    timeout: Timeout(const Duration(minutes: 1)),
  );
  test(
    'player-previous-playlist-mode-loop',
    () async {
      final player = await Player.create();

      final playable = Playlist([
        for (int i = 0; i < sources.platform.length; i++)
          Media(sources.platform[i]),
      ]);
      expect(
        player.stream.playlist,
        emitsInOrder([
          playable,
          // index: sources.platform.length - 1 -> 0
          for (int i = sources.platform.length - 1; i >= 0; i--)
            playable.copyWith(index: i),

          // must loop back to index: sources.platform.length - 1
          for (int i = sources.platform.length - 1; i >= 0; i--)
            playable.copyWith(index: i),
        ]),
      );

      await player.setPlaylistMode(PlaylistMode.loop);
      await player.open(playable);

      // NOTE: VOLUNTARY DELAY.
      await Future.delayed(const Duration(seconds: 5));

      await player.jump(sources.platform.length - 1);

      final timer = Timer.periodic(const Duration(seconds: 1), (_) async {
        try {
          await player.previous();
        } catch (_) {}
      });

      await Future.delayed(const Duration(seconds: 45));

      timer.cancel();
      await player.dispose();
    },
    timeout: Timeout(const Duration(minutes: 1)),
  );
  test('player-add', () async {
    final player = await Player.create();

    expect(
      player.stream.playlist,
      emitsInOrder([
        // Player.open
        Playlist([Media(sources.platform[0])], index: 0),
        // Player.add
        Playlist([
          Media(sources.platform[0]),
          Media(sources.platform[1]),
        ], index: 0),
        // index transition
        Playlist([
          Media(sources.platform[0]),
          Media(sources.platform[1]),
        ], index: 1),
        emitsDone,
      ]),
    );

    await player.open(Media(sources.platform[0]));

    // NOTE: VOLUNTARY DELAY.
    await Future.delayed(const Duration(seconds: 5));

    await player.add(Media(sources.platform[1]));

    await Future.delayed(const Duration(seconds: 30));

    await player.dispose();
  }, timeout: Timeout(const Duration(minutes: 1)));
  test(
    'player-remove-before-current-index',
    () async {
      final player = await Player.create();

      final playable = Playlist([
        for (int i = 0; i < sources.platform.length; i++)
          Media(sources.platform[i]),
      ]);

      expect(
        player.stream.playlist,
        emitsInOrder([
          // Player.open
          playable,
          // Player.jump
          playable.copyWith(index: 1),
          // Player.remove
          Playlist([
            for (int i = 0; i < sources.platform.length; i++)
              if (i != 0) Media(sources.platform[i]),
          ], index: 0),
          // index transition
          Playlist([
            for (int i = 0; i < sources.platform.length; i++)
              if (i != 0) Media(sources.platform[i]),
          ], index: 1),
        ]),
      );

      await player.open(playable);

      // NOTE: VOLUNTARY DELAY.
      await Future.delayed(const Duration(seconds: 5));

      await player.jump(1);

      // NOTE: VOLUNTARY DELAY.
      await Future.delayed(const Duration(seconds: 5));

      await player.remove(0);

      await Future.delayed(const Duration(seconds: 30));

      await player.dispose();
    },
    timeout: Timeout(const Duration(minutes: 1)),
  );
  test(
    'player-remove-after-current-index',
    () async {
      final player = await Player.create();

      final playable = Playlist([
        for (int i = 0; i < sources.platform.length; i++)
          Media(sources.platform[i]),
      ]);

      expect(
        player.stream.playlist,
        emitsInOrder([
          // Player.open
          playable,
          // Player.remove
          Playlist([
            for (int i = 0; i < sources.platform.length; i++)
              if (i != 1) Media(sources.platform[i]),
          ], index: 0),
          // index transition
          Playlist([
            for (int i = 0; i < sources.platform.length; i++)
              if (i != 1) Media(sources.platform[i]),
          ], index: 1),
        ]),
      );

      await player.open(playable);

      // NOTE: VOLUNTARY DELAY.
      await Future.delayed(const Duration(seconds: 5));

      await player.remove(1);

      await Future.delayed(const Duration(seconds: 30));

      await player.dispose();
    },
    timeout: Timeout(const Duration(minutes: 1)),
  );
  test('player-remove-current-index', () async {
    final player = await Player.create();

    final playable = Playlist([
      for (int i = 0; i < sources.platform.length; i++)
        Media(sources.platform[i]),
    ]);

    expect(
      player.stream.playlist,
      emitsInOrder([
        // Player.open
        playable,
        // Player.remove
        Playlist([
          // The next item should start playing & index will not increment because the current index is removed.
          for (int i = 0; i < sources.platform.length; i++)
            if (i != 0) Media(sources.platform[i]),
        ], index: 0),
        // index transition
        Playlist([
          for (int i = 0; i < sources.platform.length; i++)
            if (i != 0) Media(sources.platform[i]),
        ], index: 1),
      ]),
    );

    await player.open(playable);

    // NOTE: VOLUNTARY DELAY.
    await Future.delayed(const Duration(seconds: 5));

    await player.remove(0);

    await Future.delayed(const Duration(seconds: 30));

    await player.dispose();
  }, timeout: Timeout(const Duration(minutes: 1)));
  test(
    'player-remove-current-index-stop-playlist-mode-none',
    () async {
      final player = await Player.create();

      final playable = Playlist([
        for (int i = 0; i < sources.platform.length; i++)
          Media(sources.platform[i]),
      ]);

      expect(
        player.stream.playlist,
        emitsInOrder([
          // Player.open
          playable,
          // Player.jump
          Playlist([
            for (int i = 0; i < sources.platform.length; i++)
              Media(sources.platform[i]),
          ], index: sources.platform.length - 1),
          // Player.remove
          Playlist([
            for (int i = 0; i < sources.platform.length; i++)
              if (i != sources.platform.length - 1) Media(sources.platform[i]),
          ], index: sources.platform.length - 2),
        ]),
      );

      await player.setPlaylistMode(PlaylistMode.none);
      await player.open(playable);

      // NOTE: VOLUNTARY DELAY.
      await Future.delayed(const Duration(seconds: 5));

      await player.jump(sources.platform.length - 1);

      // NOTE: VOLUNTARY DELAY.
      await Future.delayed(const Duration(seconds: 5));

      await player.remove(sources.platform.length - 1);

      await Future.delayed(const Duration(seconds: 45));

      await player.dispose();
    },
    timeout: Timeout(const Duration(minutes: 1)),
  );
  test(
    'player-remove-current-index-stop-playlist-mode-single',
    () async {
      final player = await Player.create();

      final playable = Playlist([
        for (int i = 0; i < sources.platform.length; i++)
          Media(sources.platform[i]),
      ]);

      expect(
        player.stream.playlist,
        emitsInOrder([
          // Player.open
          playable,
          // Player.jump
          Playlist([
            for (int i = 0; i < sources.platform.length; i++)
              Media(sources.platform[i]),
          ], index: sources.platform.length - 1),
          // Player.remove
          Playlist([
            for (int i = 0; i < sources.platform.length; i++)
              if (i != sources.platform.length - 1) Media(sources.platform[i]),
          ], index: sources.platform.length - 2),
        ]),
      );

      await player.setPlaylistMode(PlaylistMode.single);
      await player.open(playable);

      // NOTE: VOLUNTARY DELAY.
      await Future.delayed(const Duration(seconds: 5));

      await player.jump(sources.platform.length - 1);

      // NOTE: VOLUNTARY DELAY.
      await Future.delayed(const Duration(seconds: 5));

      await player.remove(sources.platform.length - 1);

      await Future.delayed(const Duration(seconds: 45));

      await player.dispose();
    },
    timeout: Timeout(const Duration(minutes: 1)),
  );
  test(
    'player-remove-current-index-stop-playlist-mode-loop',
    () async {
      final player = await Player.create();

      final playable = Playlist([
        for (int i = 0; i < sources.platform.length; i++)
          Media(sources.platform[i]),
      ]);

      expect(
        player.stream.playlist,
        emitsInOrder([
          // Player.open
          playable,
          // Player.jump
          Playlist([
            for (int i = 0; i < sources.platform.length; i++)
              Media(sources.platform[i]),
          ], index: sources.platform.length - 1),
          // Player.remove
          Playlist(
            [
              for (int i = 0; i < sources.platform.length; i++)
                if (i != sources.platform.length - 1)
                  Media(sources.platform[i]),
            ],
            // must loop back to index: 0
            index: 0,
          ),
        ]),
      );

      await player.setPlaylistMode(PlaylistMode.loop);
      await player.open(playable);

      // NOTE: VOLUNTARY DELAY.
      await Future.delayed(const Duration(seconds: 5));

      await player.jump(sources.platform.length - 1);

      // NOTE: VOLUNTARY DELAY.
      await Future.delayed(const Duration(seconds: 5));

      await player.remove(sources.platform.length - 1);

      await Future.delayed(const Duration(seconds: 45));

      await player.dispose();
    },
    timeout: Timeout(const Duration(minutes: 1)),
  );
  test('player-set-rate-negative', () async {
    final player = await Player.create();

    expect(() async => await player.setRate(-1.0), throwsArgumentError);

    addTearDown(player.dispose);
  });
  test('player-set-pitch-negative', () async {
    final player = await Player.create(
      configuration: PlayerConfiguration(pitch: true),
    );

    expect(() async => await player.setPitch(-1.0), throwsArgumentError);

    addTearDown(player.dispose);
  }, skip: false);
  test('player-set-pitch-negative', () async {
    final player = await Player.create(
      configuration: PlayerConfiguration(pitch: true),
    );

    expect(() async => await player.setPitch(-1.0), throwsUnsupportedError);

    addTearDown(player.dispose);
  }, skip: true);
  test(
    'player-set-shuffle',
    () async {
      final player = await Player.create();

      final playable = Playlist([
        for (int i = 0; i < sources.platform.length; i++)
          Media(sources.platform[i]),
      ]);

      player.stream.playlist.listen((e) {
        print(e.medias.join('\n'));
        print('------------------------------');
      });

      expect(
        player.stream.playlist,
        emitsInOrder([
          // Player.open
          playable,
          // Player.setShuffle /w true
          TypeMatcher<Playlist>().having(
            (event) => event.medias.toSet(),
            'medias',
            equals(playable.medias.toSet()),
          ),
          // Player.setShuffle /w false
          playable,
        ]),
      );

      await player.open(playable);

      // VOLUNTARY DELAY.
      await Future.delayed(const Duration(seconds: 5));

      await player.setShuffle(true);

      await Future.delayed(const Duration(seconds: 5));

      // VOLUNTARY DELAY.
      await player.setShuffle(false);

      await Future.delayed(const Duration(seconds: 30));

      await player.dispose();
    },
    skip: kSkipFlakyTests,
    timeout: Timeout(const Duration(minutes: 1)),
  );
  test(
    'player-set-shuffle-consecutive',
    () async {
      final player = await Player.create();

      final playable = Playlist([
        for (int i = 0; i < sources.platform.length; i++)
          Media(sources.platform[i]),
      ]);

      player.stream.playlist.listen((e) {
        print(e.medias.join('\n'));
        print('------------------------------');
      });

      expect(
        player.stream.playlist,
        emitsInOrder([
          // Player.open
          playable,
          // Player.setShuffle /w true
          TypeMatcher<Playlist>().having(
            (event) => event.medias.toSet(),
            'medias',
            equals(playable.medias.toSet()),
          ),
          // Player.setShuffle /w false
          playable,
        ]),
      );

      await player.open(playable);

      // VOLUNTARY DELAY.
      await Future.delayed(const Duration(seconds: 5));

      await player.setShuffle(true);
      await player.setShuffle(true);
      await player.setShuffle(true);
      await player.setShuffle(true);
      await player.setShuffle(true);

      await Future.delayed(const Duration(seconds: 5));

      // VOLUNTARY DELAY.
      await player.setShuffle(false);
      await player.setShuffle(false);
      await player.setShuffle(false);
      await player.setShuffle(false);
      await player.setShuffle(false);

      await Future.delayed(const Duration(seconds: 30));

      await player.dispose();
    },
    skip: kSkipFlakyTests,
    timeout: Timeout(const Duration(minutes: 1)),
  );
  test(
    'player-buffering-file',
    () async {
      final player = await Player.create();

      player.stream.buffering.listen((e) => print(e));

      expect(
        player.stream.buffering,
        emitsInOrder([
          // Player.open: buffering = false
          false,
          // Player.open: buffering = true
          true,
          // Player.open: buffering = false
          false,
          // EOF
          true,
          false,
          // Player.dispose
          emitsDone,
        ]),
      );

      await player.open(Media(sources.file[0]));

      await Future.delayed(const Duration(seconds: 30));

      await player.dispose();
    },
    timeout: Timeout(const Duration(minutes: 1)),
    skip: false,
  );
  test('player-buffering-network', () async {
    final player = await Player.create();

    player.stream.buffering.listen((e) => print(e));

    expect(
      player.stream.buffering,
      emitsInOrder([
        // Player.open: buffering = false
        false,
        // Player.open: buffering = true
        true,
        // Player.open: buffering = false
        false,
        // EOF
        true,
        false,
        // Player.dispose
        emitsDone,
      ]),
    );

    await player.open(Media(sources.network[0]));

    await Future.delayed(const Duration(seconds: 30));

    await player.dispose();
  }, timeout: Timeout(const Duration(minutes: 1)));
  test(
    'player-buffering-file-play-false',
    () async {
      final player = await Player.create();

      player.stream.buffering.listen((e) => print(e));

      expect(
        player.stream.buffering,
        emitsInOrder([
          // Player.open: buffering = false
          false,
          // Player.open: buffering = true
          true,
          // Player.open: buffering = false
          false,
          // Player.dispose
          emitsDone,
        ]),
      );

      await player.open(Media(sources.file[0]), play: false);

      await Future.delayed(const Duration(seconds: 30));

      await player.dispose();
    },
    timeout: Timeout(const Duration(minutes: 1)),
    skip: false,
  );
  test(
    'player-buffering-network-play-false',
    () async {
      final player = await Player.create();

      player.stream.buffering.listen((e) => print(e));

      expect(
        player.stream.buffering,
        emitsInOrder([
          // Player.open: buffering = false
          false,
          // Player.open: buffering = true
          true,
          // Player.open: buffering = false
          false,
          // Player.dispose
          emitsDone,
        ]),
      );

      await player.open(Media(sources.network[0]), play: false);

      await Future.delayed(const Duration(seconds: 30));

      await player.dispose();
    },
    timeout: Timeout(const Duration(minutes: 1)),
  );
  test(
    'player-buffering-upon-seek',
    () async {
      final player = await Player.create();
      player.stream.buffering.listen((e) => print(e));

      expect(
        player.stream.buffering,
        emitsInOrder([
          // Player.open: buffering = false
          false,
          // Player.open: buffering = true
          true,
          // Player.open: buffering = false
          false,
          // Player.seek: buffering = true
          true,
          // Player.seek: buffering = false
          false,
          // EOF
          true,
          false,
          // Player.dispose
          emitsDone,
        ]),
      );

      // Seek to the end of the stream to trigger buffering.
      player.stream.duration.listen((event) async {
        if (event > Duration.zero) {
          // VOLUNTARY DELAY.
          await Future.delayed(const Duration(seconds: 5));

          print('Seek');

          await player.seek(event - const Duration(seconds: 30));
        }
      });

      await player.open(
        Media(
          'https://github.com/media-kit/media-kit/assets/28951144/efb4057c-6fd3-4644-a0b1-42d5fb420ce9',
        ),
      );

      await Future.delayed(const Duration(minutes: 1));

      await player.dispose();
    },
    timeout: Timeout(const Duration(minutes: 1, seconds: 30)),
  );
  test(
    'player-buffering-pause-play',
    () async {
      // When pausing in buffering state, the player must exit buffering state once resumed.
      // https://github.com/media-kit/media-kit/issues/367
      final player = await Player.create();

      player.stream.buffering.listen((e) => print(e));

      expect(
        player.stream.buffering,
        emitsInOrder([
          // Player.open: buffering = false
          false,
          // Player.open: buffering = true
          true,
          // Player.open: buffering = false
          false,
          // Player.seek: buffering = true
          true,
          // Player.play: buffering = false
          false,
          // EOF
          true,
          false,
          // Player.dispose
          emitsDone,
        ]),
      );

      // Seek to the end of the stream to trigger buffering.
      player.stream.duration.listen((event) async {
        if (event > Duration.zero) {
          // VOLUNTARY DELAY.
          await Future.delayed(const Duration(seconds: 5));

          print('Seek');

          await player.seek(event - const Duration(seconds: 30));

          print('Buffering...');

          // Wait until buffering is started.
          await player.stream.buffering.firstWhere((e) => e);

          print('Wait...');
          print('Pause');

          await player.pause();

          // VOLUNTARY DELAY.
          await Future.delayed(const Duration(seconds: 5));

          print('Play');

          await player.play();
        }
      });

      await player.open(
        Media(
          'https://github.com/media-kit/media-kit/assets/28951144/efb4057c-6fd3-4644-a0b1-42d5fb420ce9',
        ),
      );

      await Future.delayed(const Duration(minutes: 1));

      await player.dispose();
    },
    timeout: Timeout(const Duration(minutes: 1, seconds: 30)),
  );
  test('player-buffering-playlist', () async {
    final player = await Player.create();

    player.stream.playlist.listen((e) => print(e.index));
    player.stream.completed.listen((e) => print('completed: $e'));
    player.stream.buffering.listen((e) => print('buffering: $e'));

    expect(
      player.stream.buffering,
      emitsInOrder([
        // 0

        // Player.open: buffering = false
        false,
        // Player.open: buffering = true
        true,
        // Player.open: buffering = false
        false,
        // EOF
        true,
        false,

        // 1

        // Player.open: buffering = false
        // false,

        // Player.open: buffering = true
        true,
        // Player.open: buffering = false
        false,
        // EOF
        true,
        false,

        // 2

        // Player.open: buffering = false
        // false,

        // Player.open: buffering = true
        true,
        // Player.open: buffering = false
        false,
        // EOF
        true,
        false,

        // 3

        // Player.open: buffering = false
        // false,

        // Player.open: buffering = true
        true,
        // Player.open: buffering = false
        false,
        // EOF
        true,
        false,

        // Player.dispose
        emitsDone,
      ]),
    );

    await player.open(
      Playlist([
        for (int i = 0; i < sources.network.length; i++)
          Media(sources.network[i]),
      ]),
    );

    await Future.delayed(const Duration(minutes: 1, seconds: 30));

    await player.dispose();
  }, timeout: Timeout(const Duration(minutes: 2)));
  test(
    'player-stop',
    () async {
      final player = await Player.create();

      await player.open(Media(sources.platform[0]));

      // VOLUNTARY DELAY.
      await Future.delayed(const Duration(seconds: 5));

      await player.stop();

      // VOLUNTARY DELAY.
      await Future.delayed(const Duration(seconds: 5));

      print(player.state);

      expect(player.state.playlist, equals(Playlist([])));
      expect(player.state.playing, equals(false));
      expect(player.state.completed, equals(false));
      expect(player.state.position, equals(Duration.zero));
      expect(player.state.duration, equals(Duration.zero));
      expect(player.state.buffering, equals(false));
      expect(player.state.buffer, equals(Duration.zero));
      expect(player.state.audioParams, equals(const AudioParams()));
      expect(player.state.videoParams, equals(const VideoParams()));
      expect(player.state.track, equals(const Track()));
      expect(player.state.tracks, equals(const Tracks()));
      expect(player.state.width, equals(null));
      expect(player.state.height, equals(null));
      expect(player.state.subtitle, equals(const Subtitle.raw()));

      // VOLUNTARY DELAY.
      await Future.delayed(const Duration(seconds: 5));

      await player.dispose();
    },
    skip: kSkipFlakyTests,
    timeout: Timeout(const Duration(minutes: 2)),
  );
  test('player-stop-open', () async {
    final player = await Player.create();

    await player.open(Media(sources.platform[0]));

    // VOLUNTARY DELAY.
    await Future.delayed(const Duration(seconds: 5));

    await player.stop();

    // VOLUNTARY DELAY.
    await Future.delayed(const Duration(seconds: 5));

    final expectPosition = expectAsync1(
      (value) {
        print(value);
        expect(value, isA<Duration>());
      },
      count: 1,
      max: -1,
    );

    player.stream.position.listen((event) async {
      if (event > Duration.zero) {
        print(event);
        expectPosition(event);
      }
    });

    await player.open(Media(sources.platform[0]));

    // VOLUNTARY DELAY.
    await Future.delayed(const Duration(seconds: 5));

    await player.dispose();
  }, timeout: Timeout(const Duration(minutes: 2)));
  test(
    'player-screenshot',
    () async {
      final player = await Player.create();

      await player.open(Media(sources.platform[0]));

      // VOLUNTARY DELAY.
      await Future.delayed(const Duration(seconds: 5));

      final screenshot = await player.screenshot();

      expect(screenshot, isNotNull);
      expect(screenshot, isA<ui.Image>());

      // VOLUNTARY DELAY.
      await Future.delayed(const Duration(seconds: 5));

      await player.dispose();
    },
    timeout: Timeout(const Duration(minutes: 2)),
    skip: false,
  );
  test(
    'player-screenshot',
    () async {
      final player = await Player.create();

      await player.open(Media(sources.platform[0]));

      // VOLUNTARY DELAY.
      await Future.delayed(const Duration(seconds: 5));

      // CORS
      final screenshot = await player.screenshot();

      expect(screenshot, isNull);

      // VOLUNTARY DELAY.
      await Future.delayed(const Duration(seconds: 5));

      await player.dispose();
    },
    timeout: Timeout(const Duration(minutes: 2)),
    skip: true,
  );
  test(
    'player-screenshot-format',
    () async {
      final player = await Player.create();

      await player.open(Media(sources.platform[0]));

      // VOLUNTARY DELAY.
      await Future.delayed(const Duration(seconds: 5));

      // CORS
      final screenshot = await player.screenshot();

      expect(screenshot, isNull);

      // VOLUNTARY DELAY.
      await Future.delayed(const Duration(seconds: 5));

      await player.dispose();
    },
    timeout: Timeout(const Duration(minutes: 2)),
    skip: true,
  );
  test(
    'player-subtitle',
    () async {
      final player = await Player.create();

      player.stream.tracks.listen((event) {
        print(event);
      });
      player.stream.subtitle.listen((subtitle) {
        print(subtitle);
      });

      expect(
        player.stream.tracks,
        emitsInOrder([
          // Player.open
          Tracks(),
          Tracks(
            video: [
              VideoTrack('auto', null, null),
              VideoTrack('no', null, null),
              VideoTrack('1', null, null),
            ],
            audio: [
              AudioTrack('auto', null, null),
              AudioTrack('no', null, null),
              AudioTrack('1', null, null),
              AudioTrack('2', 'Commentary', 'eng'),
            ],
            subtitle: [
              SubtitleTrack('auto', null, null),
              SubtitleTrack('no', null, null),
              SubtitleTrack('1', null, 'eng'),
              SubtitleTrack('2', null, 'hun'),
              SubtitleTrack('3', null, 'ger'),
              SubtitleTrack('4', null, 'fre'),
              SubtitleTrack('5', null, 'spa'),
              SubtitleTrack('6', null, 'ita'),
              SubtitleTrack('7', null, 'jpn'),
              SubtitleTrack('8', null, 'null'),
            ],
          ),
          // EOF
          Tracks(),
          emitsDone,
        ]),
      );

      expect(
        player.stream.subtitle,
        emitsInOrder([
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, ['', '']),
            '',
            isTrue,
          ),
          // SAME VALUE!
          // TypeMatcher<List<String>>().having(
          //   (subtitle) => ListEquality().equals(
          //     subtitle,
          //     ['', ''],
          //   ),
          //   'subtitle',
          //   isTrue,
          // ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, [
              '...the colossus of Rhodes!',
              '',
            ]),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, ['', '']),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, ['No!', '']),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, ['', '']),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, [
              'The colossus of Rhodes\nand it is here just for you Proog.',
              '',
            ]),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, ['', '']),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) =>
                ListEquality().equals(subtitle, ['It is there...', '']),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, ['', '']),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, [
              'I\'m telling you,\nEmo...',
              '',
            ]),
            'subtitle',
            isTrue,
          ),
          emitsDone,
        ]),
      );

      await player.open(
        Media(
          'https://github.com/ietf-wg-cellar/matroska-test-files/raw/master/test_files/test5.mkv',
        ),
      );

      await Future.delayed(const Duration(seconds: 90));

      await player.dispose();
    },
    skip: false,
    timeout: Timeout(const Duration(minutes: 2)),
  );
  test(
    'player-tracks-playlist',
    () async {
      final player = await Player.create();

      player.stream.tracks.listen((event) {
        print(event);
      });

      expect(
        player.stream.tracks,
        emitsInOrder([
          // Player.open
          Tracks(),
          Tracks(
            video: [
              VideoTrack('auto', null, null),
              VideoTrack('no', null, null),
              VideoTrack('1', null, null),
            ],
            audio: [
              AudioTrack('auto', null, null),
              AudioTrack('no', null, null),
              AudioTrack('1', null, null),
              AudioTrack('2', 'Commentary', 'eng'),
            ],
            subtitle: [
              SubtitleTrack('auto', null, null),
              SubtitleTrack('no', null, null),
              SubtitleTrack('1', null, 'eng'),
              SubtitleTrack('2', null, 'hun'),
              SubtitleTrack('3', null, 'ger'),
              SubtitleTrack('4', null, 'fre'),
              SubtitleTrack('5', null, 'spa'),
              SubtitleTrack('6', null, 'ita'),
              SubtitleTrack('7', null, 'jpn'),
              SubtitleTrack('8', null, 'null'),
            ],
          ),
          Tracks(),
          Tracks(
            video: [
              VideoTrack('auto', null, null),
              VideoTrack('no', null, null),
              VideoTrack('1', null, null),
            ],
            audio: [
              AudioTrack('auto', null, null),
              AudioTrack('no', null, null),
              AudioTrack('1', null, null),
              AudioTrack('2', 'Commentary', 'eng'),
            ],
            subtitle: [
              SubtitleTrack('auto', null, null),
              SubtitleTrack('no', null, null),
              SubtitleTrack('1', null, 'eng'),
              SubtitleTrack('2', null, 'hun'),
              SubtitleTrack('3', null, 'ger'),
              SubtitleTrack('4', null, 'fre'),
              SubtitleTrack('5', null, 'spa'),
              SubtitleTrack('6', null, 'ita'),
              SubtitleTrack('7', null, 'jpn'),
              SubtitleTrack('8', null, 'null'),
            ],
          ),
          // EOF
          Tracks(),
          emitsDone,
        ]),
      );

      await player.open(
        Playlist([
          Media(
            'https://github.com/ietf-wg-cellar/matroska-test-files/raw/master/test_files/test5.mkv',
          ),
          Media(
            'https://github.com/ietf-wg-cellar/matroska-test-files/raw/master/test_files/test5.mkv',
          ),
        ]),
      );

      await Future.delayed(const Duration(minutes: 2));

      await player.dispose();
    },
    skip: false,
    timeout: Timeout(const Duration(minutes: 3)),
  );
  test(
    'player-set-subtitle-track-external-uri',
    () async {
      final player = await Player.create(
        configuration: const PlayerConfiguration(logLevel: MPVLogLevel.v),
      );

      player.stream.log.listen((event) {
        print(event);
      });
      player.stream.track.listen((event) {
        print(event);
      });
      player.stream.subtitle.listen((event) {
        print(event);
      });

      expect(
        player.stream.track,
        emitsInOrder([
          Track(
            video: VideoTrack.auto(),
            audio: AudioTrack.auto(),
            subtitle: SubtitleTrack.uri(
              'https://www.iandevlin.com/html5test/webvtt/upc-video-subtitles-en.vtt',
              title: 'English',
              language: 'en',
            ),
          ),
          Track(
            video: VideoTrack.auto(),
            audio: AudioTrack.auto(),
            subtitle: SubtitleTrack.auto(),
          ),
          // Player.dispose
          Track(
            video: VideoTrack.no(),
            audio: AudioTrack.auto(),
            subtitle: SubtitleTrack.auto(),
          ),
          Track(
            video: VideoTrack.no(),
            audio: AudioTrack.no(),
            subtitle: SubtitleTrack.auto(),
          ),
          Track(
            video: VideoTrack.no(),
            audio: AudioTrack.no(),
            subtitle: SubtitleTrack.no(),
          ),
          emitsDone,
        ]),
      );
      expect(
        player.stream.subtitle,
        emitsInOrder([
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, ['', '']),
            'subtitle',
            isTrue,
          ),
          // SAME VALUE!
          // TypeMatcher<List<String>>().having(
          //   (subtitle) => ListEquality().equals(
          //     subtitle,
          //     ['', ''],
          //   ),
          //   'subtitle',
          //   isTrue,
          // ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, [
              'Everyone wants the most from life',
              '',
            ]),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, ['', '']),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, [
              'Like internet experiences that are rich and entertaining',
              '',
            ]),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, ['', '']),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, [
              'Phone conversations where people truly connect',
              '',
            ]),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, ['', '']),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, [
              'Your favourite TV programmes ready to watch at the touch of a button',
              '',
            ]),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, ['', '']),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, [
              'Which is why we are bringing TV, internet and phone together in one super package',
              '',
            ]),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, ['', '']),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, [
              'One simple way to get everything',
              '',
            ]),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, ['', '']),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, ['UPC', '']),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, ['', '']),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) =>
                ListEquality().equals(subtitle, ['Simply for everyone', '']),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, ['', '']),
            'subtitle',
            isTrue,
          ),
          emitsDone,
        ]),
      );

      await player.open(
        Media(
          'https://www.iandevlin.com/html5test/webvtt/v/upc-tobymanley.theora.ogg',
        ),
      );
      await player.setSubtitleTrack(
        SubtitleTrack.uri(
          'https://www.iandevlin.com/html5test/webvtt/upc-video-subtitles-en.vtt',
          title: 'English',
          language: 'en',
        ),
      );

      await Future.delayed(const Duration(minutes: 1));

      await player.dispose();
    },
    skip: kSkipFlakyTests,
    timeout: Timeout(const Duration(minutes: 2)),
  );
  test(
    'player-set-subtitle-track-external-data',
    () async {
      final webvtt = '''WEBVTT FILE

1
00:00:03.500 --> 00:00:05.000 D:vertical A:start
Everyone wants the most from life

2
00:00:06.000 --> 00:00:09.000 A:start
Like internet experiences that are rich <b>and</b> entertaining

3
00:00:11.000 --> 00:00:14.000 A:end
Phone conversations where people truly <c.highlight>connect</c>

4
00:00:14.500 --> 00:00:18.000
Your favourite TV programmes ready to watch at the touch of a button

5
00:00:19.000 --> 00:00:24.000
Which is why we are bringing TV, internet and phone together in <c.highlight>one</c> super package

6
00:00:24.500 --> 00:00:26.000
<c.highlight>One</c> simple way to get everything

7
00:00:26.500 --> 00:00:27.500 L:12%
UPC

8
00:00:28.000 --> 00:00:30.000 L:75%
Simply for <u>everyone</u>
''';

      final player = await Player.create();

      player.stream.track.listen((event) {
        print(event);
      });
      player.stream.subtitle.listen((event) {
        print(event);
      });

      final file = await File(
        join(
          Directory.systemTemp.path,
          'player-subtitle-reset-set-subtitle-track-subtitle-track-no.vtt',
        ),
      ).writeAsString(webvtt);

      expect(
        player.stream.track,
        emitsInOrder([
          Track(
            video: VideoTrack.auto(),
            audio: AudioTrack.auto(),
            subtitle: SubtitleTrack.uri(
              file.absolute.uri.toString(),
              title: 'English',
              language: 'en',
            ),
          ),
          Track(
            video: VideoTrack.auto(),
            audio: AudioTrack.auto(),
            subtitle: SubtitleTrack.auto(),
          ),
          // Player.dispose
          Track(
            video: VideoTrack.no(),
            audio: AudioTrack.auto(),
            subtitle: SubtitleTrack.auto(),
          ),
          Track(
            video: VideoTrack.no(),
            audio: AudioTrack.no(),
            subtitle: SubtitleTrack.auto(),
          ),
          Track(
            video: VideoTrack.no(),
            audio: AudioTrack.no(),
            subtitle: SubtitleTrack.no(),
          ),
          emitsDone,
        ]),
      );
      expect(
        player.stream.subtitle,
        emitsInOrder([
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, ['', '']),
            'subtitle',
            isTrue,
          ),
          // SAME VALUE!
          // TypeMatcher<List<String>>().having(
          //   (subtitle) => ListEquality().equals(
          //     subtitle,
          //     ['', ''],
          //   ),
          //   'subtitle',
          //   isTrue,
          // ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, [
              'Everyone wants the most from life',
              '',
            ]),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, ['', '']),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, [
              'Like internet experiences that are rich and entertaining',
              '',
            ]),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, ['', '']),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, [
              'Phone conversations where people truly connect',
              '',
            ]),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, ['', '']),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, [
              'Your favourite TV programmes ready to watch at the touch of a button',
              '',
            ]),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, ['', '']),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, [
              'Which is why we are bringing TV, internet and phone together in one super package',
              '',
            ]),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, ['', '']),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, [
              'One simple way to get everything',
              '',
            ]),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, ['', '']),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, ['UPC', '']),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, ['', '']),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) =>
                ListEquality().equals(subtitle, ['Simply for everyone', '']),
            'subtitle',
            isTrue,
          ),
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, ['', '']),
            'subtitle',
            isTrue,
          ),
          emitsDone,
        ]),
      );

      await player.open(
        Media(
          'https://www.iandevlin.com/html5test/webvtt/v/upc-tobymanley.theora.ogg',
        ),
      );
      await player.setSubtitleTrack(
        SubtitleTrack.uri(
          file.absolute.uri.toString(),
          title: 'English',
          language: 'en',
        ),
      );

      await Future.delayed(const Duration(minutes: 1));

      await player.dispose();

      await file.delete();
    },
    skip: kSkipFlakyTests,
    timeout: Timeout(const Duration(minutes: 2)),
  );
  test(
    'player-web-player-hls',
    () async {
      final player = await Player.create();

      final expectPosition = expectAsync1(
        (value) {
          print(value);
          expect(value, isA<Duration>());
        },
        count: 1,
        max: -1,
      );

      player.stream.position.listen((event) async {
        if (event > Duration.zero) {
          expectPosition(event);
        }
      });
      player.stream.duration.listen((event) async {
        print(event);
      });

      // Ensure successful playback of a .m3u8 stream.
      // https://github.com/video-dev/hls.js/blob/master/tests/test-streams.js

      await player.open(
        Media('https://test-streams.mux.dev/x36xhzz/x36xhzz.m3u8'),
      );

      await Future.delayed(const Duration(minutes: 1));

      await player.dispose();
    },
    skip: true,
    timeout: Timeout(const Duration(minutes: 2)),
  );
  test('player-subtitle-reset-open', () async {
    final player = await Player.create();

    final subtitle = '''WEBVTT FILE

1
00:00:00.000 --> 00:00:15.000
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
''';

    player.stream.subtitle.listen((event) => print(event));

    expect(
      player.stream.subtitle,
      emitsInOrder([
        // Player.open
        TypeMatcher<List<String>>().having(
          (subtitle) => ListEquality().equals(subtitle, ['', '']),
          'subtitle',
          isTrue,
        ),
        // Player.setSubtitleTrack
        TypeMatcher<List<String>>().having(
          (subtitle) => ListEquality().equals(subtitle, [
            'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
            '',
          ]),
          'subtitle',
          isTrue,
        ),
        // MUST BE RESET!
        // Player.open
        TypeMatcher<List<String>>().having(
          (subtitle) => ListEquality().equals(subtitle, ['', '']),
          'subtitle',
          isTrue,
        ),
      ]),
    );

    await player.open(Media(sources.platform[0]));
    final file = await File(
      join(Directory.systemTemp.path, 'player-subtitle-reset-open.vtt'),
    ).writeAsString(subtitle);
    await player.setSubtitleTrack(
      SubtitleTrack.uri(file.absolute.uri.toString()),
    );

    await Future.delayed(const Duration(seconds: 5));

    // Player.state.subtitle & Player.stream.subtitle must be reset.
    await player.open(Media(sources.platform[0]));

    await Future.delayed(const Duration(seconds: 15));

    await player.dispose();

    await file.delete();
  }, skip: kSkipFlakyTests);
  test(
    'player-subtitle-reset-set-subtitle-track-subtitle-track-no',
    () async {
      final player = await Player.create();

      final subtitle = '''WEBVTT FILE

1
00:00:00.000 --> 00:00:15.000
Lorem ipsum dolor sit amet, consectetur adipiscing elit.
''';

      player.stream.subtitle.listen((event) => print(event));

      expect(
        player.stream.subtitle,
        emitsInOrder([
          // Player.open
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, ['', '']),
            'subtitle',
            isTrue,
          ),
          // Player.setSubtitleTrack
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, [
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
              '',
            ]),
            'subtitle',
            isTrue,
          ),
          // MUST BE RESET!
          // Player.setSubtitleTrack
          TypeMatcher<List<String>>().having(
            (subtitle) => ListEquality().equals(subtitle, ['', '']),
            'subtitle',
            isTrue,
          ),
        ]),
      );

      await player.open(Media(sources.platform[0]));
      final file = await File(
        join(
          Directory.systemTemp.path,
          'player-subtitle-reset-set-subtitle-track-subtitle-track-no.vtt',
        ),
      ).writeAsString(subtitle);
      await player.setSubtitleTrack(
        SubtitleTrack.uri(file.absolute.uri.toString()),
      );

      await Future.delayed(const Duration(seconds: 5));

      // Player.state.subtitle & Player.stream.subtitle must be reset.
      await player.setSubtitleTrack(SubtitleTrack.no());

      await Future.delayed(const Duration(seconds: 15));

      await player.dispose();

      await file.delete();
    },
    skip: kSkipFlakyTests,
  );
}

List<T> move<T>(List<T> list, int from, int to) {
  final map = SplayTreeMap<double, T>.from(
    list.asMap().map((key, value) => MapEntry(key * 1.0, value)),
  );
  final item = map.remove(from * 1.0);
  if (item != null) {
    map[to - 0.5] = item;
  }
  return map.values.toList();
}

const kSkipFlakyTests = true;
