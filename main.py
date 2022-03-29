import itertools
import habitat


env = habitat.Env(config=habitat.get_config("objectnav_mp3d.yaml"))
for i in itertools.count():
    print(i)
    env.reset()
    done = False
    while not done:
        action = env.action_space.sample()
        env.step(action)
        done = env.episode_over
