import itertools
import habitat
import numpy as np
from PIL import Image


env = habitat.Env(config=habitat.get_config("config.yaml"))
env.seed(0)
obs = env.reset()
rgb = obs["rgb"]
semantic = np.expand_dims(obs["semantic"], -1)
rgb, semantic = np.broadcast_arrays(rgb, semantic)
a = np.concatenate([rgb, semantic], axis=0)
img = Image.fromarray(a, mode="RGB")
img.save("image.jpeg")
