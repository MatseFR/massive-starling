package massive.particle;

/**
 * ...
 * @author Matse
 */
class ParticleSystemDefaults 
{
	static public var AUTO_CLEAR_ON_COMPLETE:Bool = true;
	static public var RANDOM_SEED:Int = 1;
	
	static public function create(?options:ParticleSystemOptions):ParticleSystem
	{
		var ps:ParticleSystem = new ParticleSystem(options);
		#if flash
		ps.particlesFromPoolFunction = Particle.fromPoolVector;
		ps.particlesToPoolFunction = Particle.toPoolVector;
		#else
		ps.particlesFromPoolFunction = Particle.fromPoolArray;
		ps.particlesToPoolFunction = Particle.toPoolArray;
		#end
		return ps;
	}
}